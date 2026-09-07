# U3B – ROCm-Systemstack installieren

- Stand: 2026-09-07
- Status: **PASS – INSTALLATION, REPARATUR, MOK UND POSTFLIGHT ABGESCHLOSSEN**
- Downloadfreigabe: maximal 6.856.000.000 Byte Paketnutzlast
- Systemänderungsfreigabe: `graphics,rocm` einschließlich `amdgpu-dkms`

## Freigegebener Umfang

Der Benutzer hat U3B ausdrücklich freigegeben. Der vorbereitete Helfer installiert ausschließlich:

- `python3-setuptools`, `python3-wheel` und `python3-pip` als bereits simulierte Voraussetzungen;
- AMDs Radeon-Usecase `graphics,rocm`;
- dadurch `amdgpu-lib`, `rocm`, `amdgpu-dkms` und deren simulierte Abhängigkeiten.

PyTorch-, Torchvision-, Torchaudio-, Triton-, Chatterbox- und Modelldateien gehören nicht zu U3B.

## Sicherheitsgrenzen

Der Helfer stoppt vor der Nutzlastinstallation, wenn:

- nicht Kernel `6.17.0-14-generic` aktiv und dauerhaft in GRUB ausgewählt ist;
- RX 7700 XT, `amdgpu`, Gerätezugriff oder Secure Boot vom geprüften Zustand abweichen;
- die AMD-/ROCm-Paketversionen vom U3A-Plan abweichen;
- Entfernungen, Purges oder Upgrades geplant werden;
- mehr als 444 neue Pakete oder mehr als 6.856.000.000 Byte Paketdownload vorgesehen sind;
- weniger als 30 GB freier Platz auf `/` vorhanden ist.

Ein Installationsfehler nach Beginn der Paketänderungen wird nicht automatisch mit einer riskanten Deinstallation beantwortet. In diesem Fall ist sofort zu stoppen und die vollständige Terminalausgabe an Codex zu geben.

## Ausführung

Im normalen Ubuntu-Terminal:

```bash
cd /home/tille/Projects/TilleVoiceStudio
bash scripts/u3b_install_rocm.sh
```

Das Skript wird als normaler Benutzer gestartet und fordert `sudo` nur gezielt an.

Wenn während der DKMS-Installation ein MOK-Passwort verlangt wird, ein temporäres Passwort selbst wählen und nur bis zum Neustart merken. Dieses Passwort niemals an Codex senden; es wird vom Helfer nicht protokolliert.

## Neustart mit Secure Boot

Nach erfolgreicher Paketinstallation kontrolliert neu starten. Falls der blaue MOK-Manager erscheint:

1. `Enroll MOK`
2. `Continue`
3. `Yes`
4. das selbst gewählte temporäre Passwort eingeben
5. Neustart abschließen lassen

Anschließend noch keine Frameworks installieren. Codex wieder im Projektordner öffnen; dann folgt U3B-Postflight mit Kernel-, DKMS-, Geräte-, `rocminfo`- und `clinfo`-Prüfung.

## Eingetretener Zwischenstand

Die Paketnutzlast wurde heruntergeladen und größtenteils installiert. `rocm`, `amdgpu-lib` und `rocminfo` sind vollständig installiert. `amdgpu-dkms` wurde für Kernel 6.17 erfolgreich gebaut, scheiterte aber zusätzlich beim Build für den weiterhin installierten Kernel 7.0 und blieb halb konfiguriert.

Nicht neu starten und U3B nicht erneut ausführen. Die freigegebene Reparatur steht in `docs/U3B_REPAIR_KERNEL7.md`.

Die Reparatur und der anschließende MOK-Neustart wurden inzwischen erfolgreich abgeschlossen. Systemseitig sind Kernel, Secure Boot, Pakete, DKMS-Modul, Signatur und GPU-Initialisierung bestätigt. Offen ist nur noch `scripts/u3b_postflight.sh` im normalen Benutzerterminal, damit `/dev/kfd`, `renderD128`, `rocminfo` und `clinfo` außerhalb der Codex-Sandbox geprüft werden.

Der erste Postflight-Lauf stoppte fälschlich, weil die ursprüngliche Prüfung ein separates Paket namens `clinfo` erwartete. AMD stellt `/usr/bin/clinfo` hier korrekt über `update-alternatives` aus dem vollständig installierten Paket `rocm-opencl` bereit. Der Helfer wurde entsprechend korrigiert und prüft nun Befehlsziel, Ausführbarkeit und Paketzuständigkeit statt eines nicht erforderlichen Zusatzpakets. Es wurde nichts nachinstalliert.

## Abschlussergebnis

Der korrigierte Postflight wurde am 2026-09-07 erfolgreich ausgeführt:

- Kernel `6.17.0-14-generic`, Secure Boot aktiviert
- signiertes AMD-DKMS-Modul 6.16.13 geladen
- Benutzer in den Gruppen `video` und `render`
- `/dev/kfd` und `/dev/dri/renderD128` effektiv les- und schreibbar
- `rocminfo`: `gfx1101`, AMD Radeon RX 7700 XT
- `clinfo`: eine OpenCL-GPU, rund 12,868 GB globaler Speicher

Nachweise: `work/u3b-postflight/summary.txt`, `rocminfo.txt`, `rocminfo.raw.txt` und `clinfo.txt`. U3B ist **PASS**.
