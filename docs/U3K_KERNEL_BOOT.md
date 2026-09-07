# U3K – unterstützten Kernel 6.17 als Bootziel festlegen

- Stand: 2026-09-07
- Status: **PASS – AUSGEFÜHRT UND NACH NEUSTART VERIFIZIERT**
- Download: 0 GB

## Anlass

U3A ist erfolgreich abgeschlossen. Nach einem Neustart wurde jedoch automatisch Kernel `7.0.0-31-generic` gestartet. AMDs ROCm-7.2.1-Kompatibilitätsmatrix nennt für Ubuntu 24.04.4 den HWE-Kernel 6.17 als unterstützte Kombination.

Der Benutzer hat anschließend über das GRUB-Menü erfolgreich `6.17.0-14-generic` gestartet. Da `/etc/default/grub` weiterhin `GRUB_DEFAULT=0`, `GRUB_TIMEOUT_STYLE=hidden` und `GRUB_TIMEOUT=0` enthält, würde ein weiterer normaler Start wieder den neueren Kernel 7.0 auswählen.

## Vorbereitete Änderung

Der Helfer `scripts/u3k_pin_kernel_6_17.sh`:

1. bricht ab, wenn nicht bereits Kernel `6.17.0-14-generic` aktiv ist;
2. prüft Kernel-, Initrd- und GRUB-Dateien;
3. ermittelt den vorhandenen, gegebenenfalls lokalisierten GRUB-Menüpfad für Kernel 6.17;
4. sichert `/etc/default/grub` mit Zeitstempel;
5. setzt den ermittelten 6.17-Menüeintrag als Standard;
6. zeigt das GRUB-Menü künftig fünf Sekunden lang an;
7. führt `update-grub` aus und prüft das Ergebnis;
8. stellt bei einem Fehler die Sicherung wieder her.

Das Skript entfernt weder Kernel noch verändert es ROCm-, Grafik- oder Framework-Pakete. Es verursacht keinen Download.

## Ausführung

Aus dem Projektordner:

```bash
sudo bash scripts/u3k_pin_kernel_6_17.sh
```

Nach erfolgreicher Ausgabe kontrolliert neu starten. Danach muss gelten:

```bash
uname -r
```

Erwartet: `6.17.0-14-generic`.

U3B darf erst nach diesem Neustart-PASS und einer separaten Download-/Systemänderungsfreigabe beginnen.

## Verifiziertes Ergebnis

Liveprüfung nach der Ausführung und dem Neustart:

- aktiver Kernel: `6.17.0-14-generic`
- `GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 6.17.0-14-generic"`
- `GRUB_TIMEOUT_STYLE=menu`
- `GRUB_TIMEOUT=5`
- Sicherung vorhanden: `/etc/default/grub.u3k-backup-20260907T202040Z`
- Secure Boot weiterhin aktiviert
- Download: 0 GB

U3K ist **PASS**. ROCm und `amdgpu-dkms` sind weiterhin nicht installiert.
