#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/tille/Projects/TilleVoiceStudio"
VENV_DIR="$PROJECT_DIR/.venv"
MAX_PAYLOAD_BYTES=2428604
EXPECTED_PACKAGES=(python3-pip-whl python3-setuptools-whl python3.12-venv)

stop() {
  printf 'STOP: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || stop "Dieses Skript als normaler Benutzer starten, nicht mit sudo."
[[ "$(python3 --version 2>&1)" == "Python 3.12.3" ]] || stop "Erwartet wird Python 3.12.3."
[[ ! -e "$VENV_DIR" ]] || stop "$VENV_DIR existiert bereits; nichts wurde verändert."

simulation="$(mktemp)"
trap 'rm -f "$simulation"' EXIT
LC_ALL=C apt-get -s -o Debug::NoLocking=1 install python3.12-venv >"$simulation"

grep -Fq '0 upgraded, 3 newly installed, 0 to remove' "$simulation" \
  || stop "APT-Simulation weicht von 3 neuen Paketen ohne Upgrade/Entfernung ab."

mapfile -t planned_packages < <(
  sed -n 's/^Inst \([^ ]*\).*/\1/p' "$simulation" | sort -u
)
mapfile -t expected_sorted < <(printf '%s\n' "${EXPECTED_PACKAGES[@]}" | sort)
[[ "${planned_packages[*]}" == "${expected_sorted[*]}" ]] \
  || stop "Ungeplante Paketliste: ${planned_packages[*]}"

payload_bytes=0
for package in "${EXPECTED_PACKAGES[@]}"; do
  candidate="$(apt-cache policy "$package" | awk '/Candidate:/ {print $2; exit}')"
  [[ -n "$candidate" && "$candidate" != '(none)' ]] || stop "Kein APT-Kandidat für $package."
  size="$(apt-cache show "$package=$candidate" | awk '/^Size:/ {print $2; exit}')"
  [[ "$size" =~ ^[0-9]+$ ]] || stop "Downloadgröße für $package nicht ermittelbar."
  payload_bytes=$((payload_bytes + size))
done
[[ "$payload_bytes" -le "$MAX_PAYLOAD_BYTES" ]] \
  || stop "Paketnutzlast $payload_bytes Byte überschreitet $MAX_PAYLOAD_BYTES Byte."

printf 'U3C1 Vorprüfung PASS: %s Byte, genau drei neue Pakete.\n' "$payload_bytes"
printf 'Installiere ausschließlich python3.12-venv und seine beiden simulierten Wheel-Pakete.\n'
sudo apt-get install --yes python3.12-venv

python3 -m venv "$VENV_DIR"
[[ -x "$VENV_DIR/bin/python" ]] || stop "Virtuelle Umgebung wurde nicht korrekt erstellt."
[[ "$($VENV_DIR/bin/python --version 2>&1)" == "Python 3.12.3" ]] \
  || stop "Unerwartete Python-Version in der virtuellen Umgebung."

site_enabled="$($VENV_DIR/bin/python -c 'import sys; print(int(any(p.startswith("/usr/lib/python3/dist-packages") for p in sys.path)))')"
[[ "$site_enabled" == "0" ]] || stop "System-Site-Packages sind unerwartet eingebunden."

printf '\nU3C1 PASS.\n'
printf 'Venv: %s\n' "$VENV_DIR"
printf 'Noch keine Framework-, Chatterbox- oder Modelldateien installiert.\n'
printf "Danach Codex im Projektordner öffnen und 'fertig' schreiben.\n"
