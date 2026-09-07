#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$PROJECT_DIR/work/u3b"
DRYRUN_PATH="$WORK_DIR/amdgpu-install-dryrun.txt"
SIMULATION_PATH="$WORK_DIR/apt-simulation.txt"
URIS_PATH="$WORK_DIR/apt-download-uris.txt"
PREFLIGHT_PATH="$WORK_DIR/preflight.txt"

TARGET_KERNEL="6.17.0-14-generic"
EXPECTED_BOOT_TARGET="Advanced options for Ubuntu>Ubuntu, with Linux 6.17.0-14-generic"
EXPECTED_INSTALLER_VERSION="30.30.1.0.30300100-2303411.24.04"
EXPECTED_ROCM_VERSION="7.2.1.70201-81~24.04"
EXPECTED_DKMS_VERSION="1:6.16.13.30300100-2303411.24.04"
EXPECTED_INSTALL_LINE="apt-get install -y amdgpu-lib rocm amdgpu-dkms linux-headers-6.17.0-14-generic linux-headers-7.0.0-31-generic"
MAX_NEW_PACKAGES=444
MAX_PAYLOAD_BYTES=6856000000
MIN_FREE_BYTES=30000000000

mkdir -p "$WORK_DIR"

stop() {
  echo "STOP: $*" >&2
  echo "Es wurde nicht automatisch zurückgerollt. Keine weiteren Paketbefehle ausführen; Ausgabe an Codex senden." >&2
  exit 1
}

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  stop "Als normaler Benutzer tille starten, nicht als root. Das Skript fordert sudo gezielt an."
fi

source /etc/os-release
[[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "24.04" ]] || \
  stop "Erwartet Ubuntu 24.04; erkannt ${ID:-unknown} ${VERSION_ID:-unknown}."
[[ $(uname -m) == "x86_64" ]] || stop "Erwartet x86_64; erkannt $(uname -m)."
[[ $(uname -r) == "$TARGET_KERNEL" ]] || \
  stop "Aktiver Kernel ist $(uname -r); erwartet wird $TARGET_KERNEL."

grep -Fqx "GRUB_DEFAULT=\"$EXPECTED_BOOT_TARGET\"" /etc/default/grub || \
  stop "Kernel 6.17 ist nicht als erwartetes dauerhaftes GRUB-Ziel eingetragen."
grep -Fqx 'GRUB_TIMEOUT_STYLE=menu' /etc/default/grub || \
  stop "Das GRUB-Menü ist nicht sichtbar konfiguriert."
grep -Fqx 'GRUB_TIMEOUT=5' /etc/default/grub || \
  stop "Der erwartete GRUB-Timeout von fünf Sekunden fehlt."

installer_version=$(dpkg-query -W -f='${Version}' amdgpu-install 2>/dev/null || true)
[[ "$installer_version" == "$EXPECTED_INSTALLER_VERSION" ]] || \
  stop "Unerwartete amdgpu-install-Version: ${installer_version:-nicht installiert}."

if dpkg-query -W -f='${db:Status-Abbrev}' rocm amdgpu-dkms 2>/dev/null | grep -q '^ii'; then
  stop "ROCm oder amdgpu-dkms ist bereits installiert; der vorbereitete Ausgangszustand stimmt nicht mehr."
fi

for device in /dev/kfd /dev/dri/renderD128; do
  [[ -r "$device" && -w "$device" ]] || \
    stop "Der Benutzer besitzt keinen Lese-/Schreibzugriff auf $device."
done

lspci -nnk | grep -A3 -i '1002:747e' | grep -q 'Kernel driver in use: amdgpu' || \
  stop "RX 7700 XT 1002:747e mit aktivem amdgpu-Treiber wurde nicht bestätigt."

secure_boot=$(mokutil --sb-state 2>/dev/null || true)
grep -q 'SecureBoot enabled' <<<"$secure_boot" || \
  stop "Secure Boot ist nicht wie geplant aktiviert."

free_bytes=$(df --output=avail -B1 / | tail -n 1 | tr -d ' ')
[[ "$free_bytes" =~ ^[0-9]+$ && "$free_bytes" -ge "$MIN_FREE_BYTES" ]] || \
  stop "Weniger als 30 GB freier Speicher auf / oder Wert nicht bestimmbar."

{
  echo "U3B preflight: $(date --iso-8601=seconds)"
  echo "Kernel: $(uname -r)"
  echo "Architecture: $(uname -m)"
  echo "Secure Boot: $secure_boot"
  echo "Free bytes on /: $free_bytes"
  echo "amdgpu-install: $installer_version"
  echo "GRUB target: $EXPECTED_BOOT_TARGET"
} > "$PREFLIGHT_PATH"

echo "U3B-Vorprüfung: PASS"
echo "Fordere sudo einmalig an ..."
sudo -v

echo "Aktualisiere Paketmetadaten ..."
sudo apt-get update

[[ $(apt-cache policy rocm | sed -n 's/^[[:space:]]*Candidate: //p') == "$EXPECTED_ROCM_VERSION" ]] || \
  stop "Der ROCm-Kandidat ist nicht mehr $EXPECTED_ROCM_VERSION."
[[ $(apt-cache policy amdgpu-dkms | sed -n 's/^[[:space:]]*Candidate: //p') == "$EXPECTED_DKMS_VERSION" ]] || \
  stop "Der amdgpu-dkms-Kandidat ist nicht mehr $EXPECTED_DKMS_VERSION."

echo "Erzeuge den aktuellen AMD-Dry-Run ..."
sudo amdgpu-install -y --usecase=graphics,rocm --dryrun > "$DRYRUN_PATH" 2>&1
cat "$DRYRUN_PATH"
grep -Fqx "$EXPECTED_INSTALL_LINE" "$DRYRUN_PATH" || \
  stop "Der AMD-Dry-Run weicht vom freigegebenen Installationsziel ab."

echo "Simuliere den vollständig freigegebenen Paketsatz ..."
apt-get --simulate install \
  python3-setuptools python3-wheel python3-pip \
  amdgpu-lib rocm amdgpu-dkms \
  linux-headers-6.17.0-14-generic linux-headers-7.0.0-31-generic \
  > "$SIMULATION_PATH"

if grep -Eq '^(Remv|Purg) ' "$SIMULATION_PATH"; then
  stop "Die APT-Simulation enthält Entfernungen oder Purges."
fi
if grep -Eq '^[1-9][0-9]* upgraded,' "$SIMULATION_PATH"; then
  stop "Die APT-Simulation enthält Paket-Upgrades."
fi

new_packages=$(sed -n 's/^0 upgraded, \([0-9][0-9]*\) newly installed,.*/\1/p' "$SIMULATION_PATH" | tail -n 1)
[[ "$new_packages" =~ ^[0-9]+$ ]] || stop "Die Zahl neuer Pakete konnte nicht gelesen werden."
[[ "$new_packages" -le "$MAX_NEW_PACKAGES" ]] || \
  stop "$new_packages neue Pakete überschreiten die Freigabe von maximal $MAX_NEW_PACKAGES."

echo "Ermittle die aktuelle Downloadgröße, ohne Paketdateien zu laden ..."
apt-get --yes --download-only --print-uris install \
  python3-setuptools python3-wheel python3-pip \
  amdgpu-lib rocm amdgpu-dkms \
  linux-headers-6.17.0-14-generic linux-headers-7.0.0-31-generic \
  > "$URIS_PATH"

payload_bytes=$(awk '$1 ~ /^.https?:\/\// && $3 ~ /^[0-9]+$/ {sum += $3} END {printf "%.0f", sum}' "$URIS_PATH")
[[ "$payload_bytes" =~ ^[0-9]+$ ]] || stop "Die Downloadgröße konnte nicht bestimmt werden."
[[ "$payload_bytes" -le "$MAX_PAYLOAD_BYTES" ]] || \
  stop "$payload_bytes Byte überschreiten die Freigabe von $MAX_PAYLOAD_BYTES Byte."

printf 'Freigegebene Simulation: %s neue Pakete, %s Byte (%.3f GB) Download.\n' \
  "$new_packages" "$payload_bytes" "$(awk -v b="$payload_bytes" 'BEGIN {print b/1000000000}')"
echo "$payload_bytes" > "$WORK_DIR/approved-payload-bytes.txt"

echo
echo "Ab jetzt beginnt die freigegebene Systeminstallation."
echo "Falls ein MOK-Passwort verlangt wird: selbst wählen, bis zum Neustart merken und niemals weitergeben."
echo "Installiere Python-Voraussetzungen ..."
sudo apt-get install -y python3-setuptools python3-wheel python3-pip

echo "Installiere AMD Radeon graphics,rocm ..."
sudo amdgpu-install -y --usecase=graphics,rocm

echo "Prüfe den Paket- und DKMS-Zustand ..."
for package in amdgpu-lib rocm amdgpu-dkms rocminfo; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  [[ "$status" == "ii " ]] || stop "$package ist nach der Installation nicht vollständig installiert."
done

audit_output=$(dpkg --audit)
[[ -z "$audit_output" ]] || stop "dpkg meldet unvollständige Pakete: $audit_output"

dkms_output=$(dkms status 2>/dev/null || true)
printf '%s\n' "$dkms_output" > "$WORK_DIR/dkms-status-before-reboot.txt"
grep -F "$TARGET_KERNEL" <<<"$dkms_output" | grep -q 'installed' || \
  stop "Für $TARGET_KERNEL wurde kein installierter amdgpu-DKMS-Eintrag bestätigt."

{
  dpkg-query -W -f='${binary:Package}\t${Version}\t${Status}\n' \
    amdgpu-lib rocm amdgpu-dkms rocminfo
  echo
  echo "DKMS:"
  printf '%s\n' "$dkms_output"
  echo
  echo "Pending MOK keys:"
  mokutil --list-new 2>/dev/null || true
} > "$WORK_DIR/post-install-before-reboot.txt"

echo
echo "U3B-Paketinstallation abgeschlossen. Noch kein ROCm-PASS: Neustartprüfung steht aus."
echo "Jetzt kontrolliert neu starten. Falls MOK Manager erscheint: Enroll MOK -> Continue -> Yes"
echo "und das selbst gewählte temporäre Passwort eingeben. Anschließend erneut neu starten lassen."
echo "Nach dem Desktopstart noch keine weiteren Installationen ausführen und Codex wieder öffnen."
