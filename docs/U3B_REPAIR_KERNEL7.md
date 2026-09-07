# U3B-Reparatur – DKMS-Konflikt mit installiertem Kernel 7.0

- Stand: 2026-09-07
- Status: **PASS – AUSGEFÜHRT UND NACH NEUSTART SYSTEMSEITIG VERIFIZIERT**
- Download: 0 GB

## Diagnose

Die U3B-Nutzlast wurde installiert. `rocm`, `amdgpu-lib` und `rocminfo` sind vollständig vorhanden. `amdgpu-dkms` blieb jedoch im Zustand `install ok half-configured`.

Das Build für den aktiven und unterstützten Kernel `6.17.0-14-generic` war erfolgreich und wird von `dkms status` als `installed` gemeldet. Der Paket-Postinstallationslauf versuchte zusätzlich den installierten neuesten Kernel `7.0.0-31-generic` zu bauen. Dieses Build scheiterte an inkompatiblen Kernel-Schnittstellen, unter anderem `dma_map_ops.map_resource`, `drm_client_dev_suspend`, `zone_device_page_init` und `pci_resize_resource`.

## Freigegebene Reparatur

Der Benutzer hat die kontrollierte Entfernung genau dieser fünf nicht aktiven Pakete freigegeben:

- `linux-generic-hwe-24.04`
- `linux-headers-7.0.0-31-generic`
- `linux-headers-generic-hwe-24.04`
- `linux-image-7.0.0-31-generic`
- `linux-image-generic-hwe-24.04`

Kernel `6.17.0-14-generic`, seine Header und sein GRUB-Standardziel bleiben erhalten. Es wird kein `autoremove` ausgeführt. Danach werden die unterbrochene Paketkonfiguration und GRUB erneut erzeugt und vollständig geprüft.

## Ausführung

Im normalen Ubuntu-Terminal:

```bash
cd /home/tille/Projects/TilleVoiceStudio
bash scripts/u3b_repair_remove_kernel_7.sh
```

Das Skript als normaler Benutzer starten; es fordert `sudo` gezielt an. Wenn erneut nach einem MOK-Passwort gefragt wird, dasselbe temporäre Passwort wie zuvor verwenden.

Nur wenn das Skript ausdrücklich Erfolg meldet, neu starten und eine angebotene MOK-Einschreibung abschließen. Bei `STOP:` oder einem Paketfehler nicht neu starten und die Terminalausgabe an Codex senden.

## Ergebnis nach Neustart

- aktiver Kernel: `6.17.0-14-generic`
- Secure Boot: aktiviert
- eingeschriebener lokaler MOK-Schlüssel vom Kernel geladen
- `amdgpu-dkms`: vollständig installiert
- DKMS: AMDGPU 6.16.13 für Kernel 6.17 `installed`
- ausgewähltes und geladenes Modul: `/lib/modules/6.17.0-14-generic/updates/dkms/amdgpu.ko.zst`
- Modulversion: 6.16.13
- Modulsignatur: vorhanden
- `rocm`, `amdgpu-lib`, `rocminfo` und `rocm-opencl`: vollständig installiert

Die Reparatur ist **PASS**. Der wegen der eingeschränkten Codex-Gerätenamespace im normalen Benutzerterminal ausgeführte Geräte-/ROCm-Postflight ist ebenfalls **PASS**: Gerätezugriff, `gfx1101`, RX 7700 XT und genau ein OpenCL-GPU-Gerät wurden bestätigt.
