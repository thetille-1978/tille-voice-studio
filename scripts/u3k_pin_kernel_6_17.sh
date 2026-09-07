#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_KERNEL="6.17.0-14-generic"
GRUB_DEFAULT_FILE="/etc/default/grub"
GRUB_CFG_FILE="/boot/grub/grub.cfg"

if [[ ${EUID} -ne 0 ]]; then
  echo "STOP: Dieses Skript muss mit sudo ausgeführt werden:"
  echo "  sudo bash scripts/u3k_pin_kernel_6_17.sh"
  exit 2
fi

if [[ $(uname -r) != "$TARGET_KERNEL" ]]; then
  echo "STOP: Aktiver Kernel ist $(uname -r), erwartet wird $TARGET_KERNEL."
  echo "Zuerst über GRUB einmalig den Kernel $TARGET_KERNEL starten."
  exit 3
fi

for required_file in \
  "$GRUB_DEFAULT_FILE" \
  "$GRUB_CFG_FILE" \
  "/boot/vmlinuz-$TARGET_KERNEL" \
  "/boot/initrd.img-$TARGET_KERNEL"
do
  if [[ ! -f "$required_file" ]]; then
    echo "STOP: Erforderliche Datei fehlt: $required_file"
    exit 4
  fi
done

submenu_title=$(sed -n "s/^[[:space:]]*submenu '\([^']*\)'.*/\1/p" "$GRUB_CFG_FILE" | head -n 1)
kernel_entry=$(sed -n "/Linux $TARGET_KERNEL/{/recovery mode/d;s/^[[:space:]]*menuentry '\([^']*\)'.*/\1/p;q;}" "$GRUB_CFG_FILE")

if [[ -z "$submenu_title" || -z "$kernel_entry" ]]; then
  echo "STOP: Der GRUB-Menüpfad für $TARGET_KERNEL konnte nicht eindeutig ermittelt werden."
  exit 5
fi

if [[ "$submenu_title" == *'"'* || "$submenu_title" == *'\\'* || \
      "$kernel_entry" == *'"'* || "$kernel_entry" == *'\\'* ]]; then
  echo "STOP: Der ermittelte GRUB-Menüpfad enthält unerwartete Zeichen."
  exit 6
fi

grub_target="$submenu_title>$kernel_entry"
timestamp=$(date -u +%Y%m%dT%H%M%SZ)
backup_file="${GRUB_DEFAULT_FILE}.u3k-backup-${timestamp}"
temp_file=$(mktemp)
changed=0

cleanup() {
  rm -f "$temp_file"
}
trap cleanup EXIT

restore_backup() {
  if [[ $changed -eq 1 ]]; then
    echo "Fehler erkannt; stelle die gesicherte GRUB-Konfiguration wieder her."
    install -o root -g root -m 0644 "$backup_file" "$GRUB_DEFAULT_FILE"
    update-grub || true
    changed=0
  fi
}
trap 'restore_backup' ERR

if [[ $(grep -c '^GRUB_DEFAULT=' "$GRUB_DEFAULT_FILE" || true) -ne 1 ||
      $(grep -c '^GRUB_TIMEOUT_STYLE=' "$GRUB_DEFAULT_FILE" || true) -ne 1 ||
      $(grep -c '^GRUB_TIMEOUT=' "$GRUB_DEFAULT_FILE" || true) -ne 1 ]]; then
  echo "STOP: Die drei erwarteten GRUB-Einstellungen sind nicht jeweils genau einmal vorhanden."
  exit 7
fi

echo "Aktiver Kernel: $(uname -r)"
echo "Ermitteltes dauerhaftes Bootziel: $grub_target"
echo "Sicherung: $backup_file"

cp --preserve=all "$GRUB_DEFAULT_FILE" "$backup_file"
cp --preserve=all "$GRUB_DEFAULT_FILE" "$temp_file"

sed -i \
  -e "s|^GRUB_DEFAULT=.*|GRUB_DEFAULT=\"$grub_target\"|" \
  -e 's|^GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=menu|' \
  -e 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=5|' \
  "$temp_file"

install -o root -g root -m 0644 "$temp_file" "$GRUB_DEFAULT_FILE"
changed=1

echo "Erzeuge die GRUB-Konfiguration neu ..."
update-grub

grep -Fqx "GRUB_DEFAULT=\"$grub_target\"" "$GRUB_DEFAULT_FILE"
grep -Fqx 'GRUB_TIMEOUT_STYLE=menu' "$GRUB_DEFAULT_FILE"
grep -Fqx 'GRUB_TIMEOUT=5' "$GRUB_DEFAULT_FILE"
grep -Fq "Linux $TARGET_KERNEL" "$GRUB_CFG_FILE"

changed=0
trap - ERR

echo
echo "U3K-Konfiguration erfolgreich. Es wurde nichts heruntergeladen."
echo "Bitte jetzt neu starten und danach prüfen: uname -r"
echo "Erwartet: $TARGET_KERNEL"
echo "Die Sicherung bleibt erhalten: $backup_file"
