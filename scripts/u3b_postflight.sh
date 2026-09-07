#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$PROJECT_DIR/work/u3b-postflight"
SUMMARY_PATH="$WORK_DIR/summary.txt"
ROCMINFO_RAW="$WORK_DIR/rocminfo.raw.txt"
ROCMINFO_PATH="$WORK_DIR/rocminfo.txt"
CLINFO_PATH="$WORK_DIR/clinfo.txt"
TARGET_KERNEL="6.17.0-14-generic"
EXPECTED_GRUB_TARGET="Advanced options for Ubuntu>Ubuntu, with Linux 6.17.0-14-generic"

stop() {
  echo "STOP: $*" >&2
  echo "Keine Installation und keinen Neustart ausführen; Ausgabe an Codex senden." >&2
  exit 1
}

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  stop "Als normaler Benutzer tille starten, nicht mit sudo."
fi

mkdir -p "$WORK_DIR"

[[ $(uname -r) == "$TARGET_KERNEL" ]] || \
  stop "Aktiver Kernel ist $(uname -r); erwartet wird $TARGET_KERNEL."
grep -Fqx "GRUB_DEFAULT=\"$EXPECTED_GRUB_TARGET\"" /etc/default/grub || \
  stop "Das dauerhafte GRUB-Ziel ist nicht mehr Kernel 6.17."

grep -qw render <<<"$(id -nG)" || stop "Der Benutzer ist nicht Mitglied der Gruppe render."
grep -qw video <<<"$(id -nG)" || stop "Der Benutzer ist nicht Mitglied der Gruppe video."

for device in /dev/kfd /dev/dri/renderD128; do
  [[ -e "$device" ]] || stop "$device fehlt."
  [[ -r "$device" && -w "$device" ]] || \
    stop "Der Benutzer besitzt keinen Lese-/Schreibzugriff auf $device."
done

for package in amdgpu-dkms amdgpu-lib rocm rocm-core rocminfo rocm-opencl; do
  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null || true)
  [[ "$status" == "ii " ]] || stop "$package ist nicht vollständig installiert: '$status'."
done

[[ $(command -v clinfo 2>/dev/null || true) == "/usr/bin/clinfo" ]] || \
  stop "Der Befehl clinfo ist nicht über /usr/bin/clinfo verfügbar."
[[ $(readlink -f /usr/bin/clinfo 2>/dev/null || true) == "/opt/rocm-7.2.1/bin/clinfo" ]] || \
  stop "clinfo verweist nicht auf die erwartete ROCm-7.2.1-Installation."
[[ -x /opt/rocm-7.2.1/bin/clinfo ]] || stop "Das AMD-clinfo-Programm ist nicht ausführbar."
dpkg -S /opt/rocm-7.2.1/bin/clinfo 2>/dev/null | grep -q '^rocm-opencl:' || \
  stop "Das AMD-clinfo-Programm gehört nicht zum erwarteten Paket rocm-opencl."

dkms_output=$(dkms status 2>/dev/null || true)
grep -F "$TARGET_KERNEL" <<<"$dkms_output" | grep -q 'installed' || \
  stop "AMD-DKMS ist für Kernel 6.17 nicht installiert."
if grep -Fq '7.0.0-31-generic' <<<"$dkms_output"; then
  stop "DKMS enthält weiterhin einen Kernel-7.0-Eintrag."
fi

[[ $(modinfo -F filename amdgpu 2>/dev/null) == */updates/dkms/amdgpu.ko* ]] || \
  stop "Der ausgewählte amdgpu-Modulpfad stammt nicht aus DKMS."
[[ $(modinfo -F version amdgpu 2>/dev/null) == "6.16.13" ]] || \
  stop "Die ausgewählte amdgpu-Modulversion ist nicht 6.16.13."
[[ -n $(modinfo -F signer amdgpu 2>/dev/null) ]] || \
  stop "Das AMD-Kernelmodul besitzt keine Secure-Boot-Signatur."
lsmod | grep -q '^amdgpu ' || stop "Das amdgpu-Kernelmodul ist nicht geladen."
grep -q 'SecureBoot enabled' <<<"$(mokutil --sb-state 2>/dev/null || true)" || \
  stop "Secure Boot ist nicht aktiviert."

if [[ -f /var/lib/shim-signed/mok/MOK.der ]]; then
  mok_test=$(mokutil --test-key /var/lib/shim-signed/mok/MOK.der 2>&1 || true)
  grep -q 'already enrolled' <<<"$mok_test" || stop "Der DKMS-MOK-Schlüssel ist nicht als eingeschrieben bestätigt."
fi

echo "Führe rocminfo aus ..."
timeout 30s rocminfo > "$ROCMINFO_RAW" 2>&1 || stop "rocminfo wurde nicht erfolgreich beendet."
sed -E 's/\x1B\[[0-9;]*[mK]//g' "$ROCMINFO_RAW" > "$ROCMINFO_PATH"

grep -Fq 'ROCk module version 6.16.13 is loaded' "$ROCMINFO_PATH" || \
  stop "rocminfo bestätigt nicht das geladene ROCk-Modul 6.16.13."
grep -Fq 'gfx1101' "$ROCMINFO_PATH" || stop "rocminfo meldet gfx1101 nicht."
grep -Eiq 'Radeon.*RX 7700 XT|RX 7700 XT' "$ROCMINFO_PATH" || \
  stop "rocminfo meldet die RX 7700 XT nicht."

echo "Führe clinfo aus ..."
timeout 30s clinfo --list > "$CLINFO_PATH" 2>&1 || stop "clinfo wurde nicht erfolgreich beendet."
grep -Eq 'Number of devices:[[:space:]]+1' "$CLINFO_PATH" || \
  stop "clinfo bestätigt nicht genau ein OpenCL-Gerät."
grep -Fq 'AMD Accelerated Parallel Processing' "$CLINFO_PATH" || \
  stop "clinfo meldet die AMD-OpenCL-Plattform nicht."

{
  echo "U3B postflight: $(date --iso-8601=seconds)"
  echo "Result: PASS"
  echo "Kernel: $(uname -r)"
  echo "Groups: $(id -nG)"
  echo "Secure Boot: $(mokutil --sb-state 2>/dev/null | tr '\n' ' ')"
  echo "amdgpu module: $(modinfo -F filename amdgpu)"
  echo "amdgpu version: $(modinfo -F version amdgpu)"
  echo "amdgpu signer: $(modinfo -F signer amdgpu)"
  echo "DKMS: $dkms_output"
  echo "Devices:"
  ls -l /dev/kfd /dev/dri/renderD128
  echo "ROCm target: gfx1101"
  echo "OpenCL devices: 1"
} > "$SUMMARY_PATH"

cat "$SUMMARY_PATH"
echo
echo "U3B-POSTFLIGHT PASS. Keine Dateien wurden heruntergeladen und keine Pakete verändert."
echo "Codex kann jetzt die Nachweise aus $WORK_DIR auswerten."
