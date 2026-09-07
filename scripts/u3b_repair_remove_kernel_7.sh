#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$PROJECT_DIR/work/u3b-repair"
SIMULATION_PATH="$WORK_DIR/removal-simulation.txt"
BEFORE_PATH="$WORK_DIR/state-before.txt"
AFTER_PATH="$WORK_DIR/state-after.txt"
TARGET_KERNEL="6.17.0-14-generic"
EXPECTED_GRUB_TARGET="Advanced options for Ubuntu>Ubuntu, with Linux 6.17.0-14-generic"

REMOVE_PACKAGES=(
  linux-generic-hwe-24.04
  linux-headers-7.0.0-31-generic
  linux-headers-generic-hwe-24.04
  linux-image-7.0.0-31-generic
  linux-image-generic-hwe-24.04
)

stop() {
  echo "STOP: $*" >&2
  echo "Nicht neu starten und kein autoremove ausführen. Ausgabe an Codex senden." >&2
  exit 1
}

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  stop "Als normaler Benutzer tille starten, nicht mit sudo bash."
fi

mkdir -p "$WORK_DIR"

[[ $(uname -r) == "$TARGET_KERNEL" ]] || \
  stop "Aktiver Kernel ist $(uname -r); erwartet wird $TARGET_KERNEL."
[[ -f "/boot/vmlinuz-$TARGET_KERNEL" && -f "/boot/initrd.img-$TARGET_KERNEL" ]] || \
  stop "Bootdateien des unterstützten Kernels $TARGET_KERNEL fehlen."
grep -Fqx "GRUB_DEFAULT=\"$EXPECTED_GRUB_TARGET\"" /etc/default/grub || \
  stop "Kernel 6.17 ist nicht mehr als dauerhaftes GRUB-Ziel eingetragen."

amdgpu_status=$(dpkg-query -W -f='${db:Status-Abbrev}' amdgpu-dkms 2>/dev/null || true)
rocm_status=$(dpkg-query -W -f='${db:Status-Abbrev}' rocm 2>/dev/null || true)
[[ "$amdgpu_status" == "iF " ]] || \
  stop "amdgpu-dkms besitzt nicht den erwarteten halb konfigurierten Zustand iF: '$amdgpu_status'."
[[ "$rocm_status" == "ii " ]] || \
  stop "ROCm besitzt nicht den erwarteten installierten Zustand: '$rocm_status'."

for package in "${REMOVE_PACKAGES[@]}"; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  [[ "$status" == "ii " ]] || stop "$package ist nicht wie erwartet installiert: '$status'."
done

dkms_before=$(dkms status 2>/dev/null || true)
grep -F "$TARGET_KERNEL" <<<"$dkms_before" | grep -q 'installed' || \
  stop "Das AMD-DKMS-Modul ist für Kernel 6.17 nicht als installiert registriert."

{
  echo "U3B repair preflight: $(date --iso-8601=seconds)"
  echo "Kernel: $(uname -r)"
  echo "GRUB target: $EXPECTED_GRUB_TARGET"
  echo
  dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Abbrev}\t${Status}\n' \
    amdgpu-dkms rocm "${REMOVE_PACKAGES[@]}" 2>/dev/null || true
  echo
  echo "DKMS:"
  printf '%s\n' "$dkms_before"
} > "$BEFORE_PATH"

echo "Simuliere die freigegebene Entfernung ..."
apt-get --simulate remove --no-auto-remove "${REMOVE_PACKAGES[@]}" > "$SIMULATION_PATH"

if grep -Eq '^Inst ' "$SIMULATION_PATH"; then
  stop "Die Simulation enthält eine unerwartete Installation oder ein Upgrade."
fi
grep -Fq '0 upgraded, 0 newly installed, 5 to remove' "$SIMULATION_PATH" || \
  stop "Die APT-Zusammenfassung weicht von exakt fünf Entfernungen ab."

mapfile -t actual_removals < <(sed -n 's/^Remv \([^ ]*\).*/\1/p' "$SIMULATION_PATH" | sort -u)
mapfile -t expected_removals < <(printf '%s\n' "${REMOVE_PACKAGES[@]}" | sort -u)

[[ ${#actual_removals[@]} -eq 5 ]] || \
  stop "Die Simulation enthält ${#actual_removals[@]} statt fünf eindeutigen Entfernungen."
[[ "${actual_removals[*]}" == "${expected_removals[*]}" ]] || {
  echo "Erwartet: ${expected_removals[*]}" >&2
  echo "Gefunden: ${actual_removals[*]}" >&2
  stop "Die simulierte Paketliste weicht von der Freigabe ab."
}

conf_packages=$(sed -n 's/^Conf \([^ ]*\).*/\1/p' "$SIMULATION_PATH" | sort -u | tr '\n' ' ')
[[ "$conf_packages" == "amdgpu-dkms " ]] || \
  stop "Die Simulation würde unerwartete Pakete konfigurieren: $conf_packages"

echo "Vorprüfung: PASS"
echo "Entfernt werden ausschließlich: ${expected_removals[*]}"
echo "Es erfolgt kein Download und ausdrücklich kein autoremove."
echo "Fordere sudo an ..."
sudo -v

echo "Entferne ausschließlich die fünf freigegebenen Kernel-7.0-/HWE-Pakete ..."
sudo apt-get remove --no-auto-remove --yes "${REMOVE_PACKAGES[@]}"

echo "Schließe die unterbrochene Paketkonfiguration ab ..."
sudo dpkg --configure -a

echo "Erzeuge GRUB neu ..."
sudo update-grub

[[ $(uname -r) == "$TARGET_KERNEL" ]] || stop "Der aktive Kernel hat sich unerwartet geändert."
[[ -f "/boot/vmlinuz-$TARGET_KERNEL" && -f "/boot/initrd.img-$TARGET_KERNEL" ]] || \
  stop "Die Bootdateien von Kernel 6.17 fehlen nach der Reparatur."
[[ ! -e /boot/vmlinuz-7.0.0-31-generic ]] || \
  stop "Das Kernel-7.0-Abbild ist nach der Entfernung weiterhin vorhanden."
grep -Fqx "GRUB_DEFAULT=\"$EXPECTED_GRUB_TARGET\"" /etc/default/grub || \
  stop "Das dauerhafte GRUB-Ziel wurde unerwartet verändert."

for package in "${REMOVE_PACKAGES[@]}"; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  [[ "$status" != "ii " ]] || stop "$package ist weiterhin installiert."
done

for package in amdgpu-dkms rocm amdgpu-lib rocminfo; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  [[ "$status" == "ii " ]] || stop "$package ist nicht vollständig konfiguriert: '$status'."
done

audit_output=$(sudo dpkg --audit)
[[ -z "$audit_output" ]] || stop "dpkg meldet weiterhin unvollständige Pakete: $audit_output"

dkms_after=$(dkms status 2>/dev/null || true)
grep -F "$TARGET_KERNEL" <<<"$dkms_after" | grep -q 'installed' || \
  stop "AMD-DKMS ist für Kernel 6.17 nach der Reparatur nicht installiert."
if grep -Fq '7.0.0-31-generic' <<<"$dkms_after"; then
  stop "DKMS enthält nach der Reparatur weiterhin einen Kernel-7.0-Eintrag."
fi

{
  echo "U3B repair completed: $(date --iso-8601=seconds)"
  echo "Kernel: $(uname -r)"
  echo "GRUB target: $EXPECTED_GRUB_TARGET"
  echo
  dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Abbrev}\t${Status}\n' \
    amdgpu-dkms rocm amdgpu-lib rocminfo 2>/dev/null
  echo
  echo "DKMS:"
  printf '%s\n' "$dkms_after"
  echo
  echo "Pending MOK keys:"
  mokutil --list-new 2>/dev/null || true
} > "$AFTER_PATH"

echo
echo "U3B-Reparatur erfolgreich. Noch nicht rocminfo ausführen."
echo "Jetzt neu starten und bei angezeigtem MOK Manager Enroll MOK -> Continue -> Yes wählen."
echo "Dasselbe temporäre Passwort wie zuvor eingeben und den Neustart abschließen lassen."
echo "Danach Codex im Projektordner öffnen und 'fertig' schreiben."
