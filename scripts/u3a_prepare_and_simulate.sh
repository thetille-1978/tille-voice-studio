#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$PROJECT_DIR/work/u3a"
DEB_NAME="amdgpu-install_7.2.1.70201-1_all.deb"
DEB_PATH="$WORK_DIR/$DEB_NAME"
PART_PATH="$DEB_PATH.part"
LOG_PATH="$WORK_DIR/u3a-session.log"
DRYRUN_PATH="$WORK_DIR/amdgpu-install-dryrun.txt"
SIMULATION_PATH="$WORK_DIR/apt-simulation.txt"
URIS_PATH="$WORK_DIR/apt-download-uris.txt"
AMD_URL="https://repo.radeon.com/amdgpu-install/7.2.1/ubuntu/noble/$DEB_NAME"
EXPECTED_BYTES=16908
EXPECTED_PACKAGE_VERSION="30.30.1.0.30300100-2303411.24.04"

mkdir -p "$WORK_DIR"
exec > >(tee -a "$LOG_PATH") 2>&1

echo "U3A started: $(date --iso-8601=seconds)"
echo "Project: $PROJECT_DIR"

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "STOP: Run this script as user tille, not as root. It requests sudo only where required." >&2
  exit 1
fi

source /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
  echo "STOP: Expected Ubuntu 24.04; detected ${ID:-unknown} ${VERSION_ID:-unknown}." >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" || "$(uname -r)" != 6.17.* ]]; then
  echo "STOP: Expected x86_64 with kernel 6.17.x; detected $(uname -m), $(uname -r)." >&2
  exit 1
fi

if ! lspci -nnk | grep -A3 -i '1002:747e' | grep -q 'Kernel driver in use: amdgpu'; then
  echo "STOP: RX 7700 XT PCI ID 1002:747e with active amdgpu driver was not confirmed." >&2
  exit 1
fi

for device in /dev/kfd /dev/dri/renderD128; do
  if [[ ! -r "$device" || ! -w "$device" ]]; then
    echo "STOP: User lacks read/write access to $device." >&2
    exit 1
  fi
done

echo "Baseline checks: PASS"
echo "Refreshing existing Ubuntu package metadata (no package installation)..."
sudo apt-get update

if [[ -f "$DEB_PATH" && "$(stat -c '%s' "$DEB_PATH")" == "$EXPECTED_BYTES" ]]; then
  echo "Reusing the already downloaded $EXPECTED_BYTES-byte AMD bootstrap package."
else
  echo "Downloading the official AMD bootstrap package..."
  wget --https-only --timeout=30 --tries=2 --output-document="$PART_PATH" "$AMD_URL"
  actual_bytes="$(stat -c '%s' "$PART_PATH")"
  if [[ "$actual_bytes" != "$EXPECTED_BYTES" ]]; then
    echo "STOP: Expected $EXPECTED_BYTES bytes, received $actual_bytes bytes. Partial file retained at $PART_PATH." >&2
    exit 1
  fi
  mv -f -- "$PART_PATH" "$DEB_PATH"
fi

package_name="$(dpkg-deb -f "$DEB_PATH" Package)"
package_version="$(dpkg-deb -f "$DEB_PATH" Version)"
package_arch="$(dpkg-deb -f "$DEB_PATH" Architecture)"
setup_conf="$(dpkg-deb --fsys-tarfile "$DEB_PATH" | tar -xOf - ./etc/amdgpu-install/amdgpu-setup.conf)"
if [[ "$package_name" != "amdgpu-install" || "$package_version" != "$EXPECTED_PACKAGE_VERSION" || "$package_arch" != "all" ]]; then
  echo "STOP: Unexpected package metadata: $package_name $package_version $package_arch." >&2
  exit 1
fi
if ! grep -qx 'RELEASE=7.2.1' <<<"$setup_conf" || ! grep -qx 'AMDGPUREL=30.30.1' <<<"$setup_conf"; then
  echo "STOP: Package does not declare the expected ROCm 7.2.1 / AMDGPU 30.30.1 repositories." >&2
  exit 1
fi
echo "Bootstrap SHA256: $(sha256sum "$DEB_PATH" | awk '{print $1}')"
echo "APT preview for the local bootstrap package..."
bootstrap_preview="$(apt-get --simulate install "$DEB_PATH")"
printf '%s\n' "$bootstrap_preview"
if grep -Eq '^(Remv|Purg) ' <<<"$bootstrap_preview"; then
  echo "STOP: Installing the bootstrap package would remove or purge packages." >&2
  exit 1
fi

echo "Installing only the AMD repository/bootstrap package..."
sudo apt-get install "$DEB_PATH"

echo "Refreshing Ubuntu and newly registered AMD metadata..."
sudo apt-get update

echo "Installed bootstrap package:"
dpkg-query -W -f='${binary:Package}\t${Version}\t${Status}\n' amdgpu-install
echo "Registered AMD sources:"
grep -R -n -i 'repo\.radeon\.com' /etc/apt/sources.list /etc/apt/sources.list.d /etc/apt/preferences.d 2>/dev/null || true

echo "Available installer use cases:"
sudo amdgpu-install --list-usecase

echo "Generating the non-writing AMD dry run..."
sudo amdgpu-install -y --usecase=graphics,rocm --dryrun | tee "$DRYRUN_PATH"

install_line="$(grep -E '^(sudo[[:space:]]+)?apt(-get)?[[:space:]]+install[[:space:]]+' "$DRYRUN_PATH" | tail -n 1 || true)"
if [[ -z "$install_line" ]]; then
  echo "STOP: Could not safely identify an APT install command in the AMD dry-run output." >&2
  exit 1
fi

read -r -a words <<<"$install_line"
packages=()
seen_install=0
for word in "${words[@]}"; do
  if [[ "$seen_install" -eq 0 ]]; then
    [[ "$word" == "install" ]] && seen_install=1
    continue
  fi
  [[ "$word" == -* ]] && continue
  if [[ "$word" =~ ^[a-z0-9][a-z0-9+.-]*([=:][a-zA-Z0-9.+:~_-]+)?$ ]]; then
    packages+=("$word")
  else
    echo "STOP: Unsafe or unexpected token in dry run: $word" >&2
    exit 1
  fi
done

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "STOP: AMD dry run yielded no package names." >&2
  exit 1
fi

echo "Safely parsed AMD package targets: ${packages[*]}"
echo "Running independent APT simulation; no packages are installed..."
apt-get --simulate install python3-setuptools python3-wheel python3-pip "${packages[@]}" | tee "$SIMULATION_PATH"

if grep -Eq '^(Remv|Purg) ' "$SIMULATION_PATH"; then
  echo "STOP: The complete simulation proposes removals or purges. Review $SIMULATION_PATH." >&2
  exit 1
fi

echo "Printing download URIs and byte sizes; package payloads are not downloaded..."
apt-get --yes --download-only --print-uris install python3-setuptools python3-wheel python3-pip "${packages[@]}" | tee "$URIS_PATH"

estimated_bytes="$(awk '$1 ~ /^.https?:\/\// && $3 ~ /^[0-9]+$/ {sum += $3} END {printf "%.0f", sum}' "$URIS_PATH")"
echo "Estimated package payload bytes: $estimated_bytes"
awk -v bytes="$estimated_bytes" 'BEGIN {printf "Estimated package payload: %.3f GB decimal / %.3f GiB\n", bytes/1000000000, bytes/1073741824}'

echo "U3A simulation complete: $(date --iso-8601=seconds)"
echo "No ROCm, graphics, DKMS, Python prerequisite, or framework package was installed."
echo "Send the contents of $LOG_PATH back to Codex for review before U3B."
