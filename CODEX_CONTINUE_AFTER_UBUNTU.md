# Tille Voice Studio – Fortsetzung nach der Ubuntu-Installation

- Stand: 2026-09-05
- Letzter erfolgreicher Checkpoint: **W7 – PASS**
Dieses Dokument verhindert, dass die bereits abgeschlossenen Windows-, ISO- und USB-Schritte nach dem Betriebssystemwechsel wiederholt werden.

## UBUNTU INSTALLATION READY

- [x] ISO-SHA256 korrekt
- [x] Ubuntu-Version kompatibel
- [x] USB-Installationsmedium erstellt und lesend verifiziert
- [x] Wiederherstellbares Backup wichtiger Daten vom Benutzer bestätigt
- [x] BitLocker-Recovery-Key behandelt: nicht erforderlich, weil alle gemeldeten Volumes vollständig entschlüsselt und der Schutz ausgeschaltet sind
- [x] Windows-Schnellstart behandelt: Ruhezustand ist deaktiviert, `C:\hiberfil.sys` fehlt; der latente Registrywert ist dokumentiert
- [x] UEFI vorhanden
- [x] Secure Boot aktiviert und dokumentiert
- [x] GPT vorhanden
- [x] Ubuntu-Speicher frei und nicht formatiert
- [x] AMD Radeon RX 7700 XT erkannt
- [x] `DOWNLOAD_BUDGET.md` aktuell
- [x] Übergabe- und Codex-Setup-Dokumente erstellt

## Bisherige Ergebnisse

| Phase | Ergebnis |
|---|---|
| W0 | PASS – Windows 11 Home 25H2, UEFI/GPT, Secure Boot aktiv, BitLocker aus, RX 7700 XT erkannt |
| W1 | PASS – offizielle Ubuntu-/ROCm-Kompatibilitätsplanung erstellt |
| W2 | PASS – Ubuntu-ISO von offizieller Quelle geladen und SHA256-verifiziert |
| W3 | PASS – Rufus Portable geprüft, SHA256 und Authenticode gültig |
| W4 | PASS – Backup bestätigt, Schnellstart funktional inaktiv, keine Verschlüsselung |
| W5 | PASS – `A:` nach Einzelfreigabe exakt um 100 GiB verkleinert |
| W6 | PASS – Ubuntu-USB-Stick im GPT-/UEFI-Modus erstellt und geprüft |
| W7 | PASS – Readiness, Übergabe und späterer Codex-Setup-Pfad geprüft |

Die bestehenden VirtualBox-VMs, insbesondere Kali und Asterisk, wurden nicht verändert.

## Ubuntu-Version und Installationsmedium

- Ziel: Ubuntu 24.04.4 LTS Desktop AMD64
- Geplanter Kernel: Ubuntu 6.17 HWE
- ISO unter Windows: `A:\TilleVoiceStudioDownloads\downloads\ubuntu-24.04.4-desktop-amd64.iso`
- ISO-Größe: 6.655.619.072 Byte
- SHA256: `3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e`
- W7-Neuberechnung der SHA256: exakte Übereinstimmung
- USB-Stick: Intenso Rainbow Line, Seriennummer `AA00000000000485`, 14,551 GiB
- USB-Aufbau: GPT, FAT32, Volume `UBUNTU 24_0`
- Verifizierte Strukturen: `.disk`, `boot`, `casper`, `EFI/BOOT`, `boot/grub`

## Partitionierung

- Ubuntu-Ziel: Datenträger 3, KINGSTON SNV3S1000G, GPT
- Bestehende NTFS-Partition `A:` nach W5: 831,511 GiB
- Freier Platz innerhalb `A:` nach W5: 113,966 GiB
- Nicht zugeordneter Bereich: 107.375.230.976 Byte / 100,001 GiB
- Der Ubuntu-Bereich ist unformatiert und besitzt keinen Laufwerksbuchstaben.
- EFI-, MSR-, Recovery-, Windows-Boot- und andere Partitionen wurden nicht verändert.

Während der Ubuntu-Installation bevorzugen:

- Deutsch und deutsche Tastatur
- Standardinstallation
- unnötige zusätzliche Downloads und Installationsupdates abwählen
- **„Ubuntu neben Windows Boot Manager installieren“**

Niemals ungeprüft auswählen:

- **„Festplatte löschen und Ubuntu installieren“**
- manuelle Formatierung vorhandener Windows-, EFI-, Recovery- oder Datenpartitionen

Falls „Ubuntu neben Windows Boot Manager installieren“ nicht angeboten wird: **STOPP**, keine Partitionsaufteilung raten und zuerst Screenshot oder Foto bereitstellen.

## Downloadbudget

- Tatsächlicher Verbrauch: 6.657.609.064 Byte / gerundet 6,658 GB
- Verbleibend tatsächlich: 13,342 GB von 20 GB
- Für spätere Codex-Installation reserviert: 0,250 GB
- Nach Reservierung noch nicht verplant: 13,092 GB
- W7-Download: 0 GB
- Die Reservierung ist keine Downloadfreigabe.

Die Ubuntu-Installation soll möglichst ohne umfangreiche Updates erfolgen. Jeder spätere Download von Systempaketen, ROCm, Python-Wheels, Chatterbox, Modellen oder Codex benötigt weiterhin die einzelne Download-Freigabe aus dem Master-Workflow.

## Geplante ROCm-/Python-Konfiguration

- GPU: AMD Radeon RX 7700 XT, RDNA3, Zielarchitektur `gfx1101`
- Ubuntu: 24.04.4 LTS Desktop AMD64
- Kernel: 6.17 HWE
- ROCm: 7.2.1, kohärenter Radeon-Produktionspfad
- Python: 3.12
- PyTorch: 2.9.1 für ROCm 7.2.1
- Torchvision: 0.24.0
- Torchaudio: 2.9.0
- Triton: 3.5.1
- Chatterbox: 0.1.7 / Multilingual V3

Maßgeblich bleibt [docs/COMPATIBILITY_PLAN.md](docs/COMPATIBILITY_PLAN.md). Noch nichts aus diesem Stack wurde installiert.

## Bekannte Risiken

1. Windows RE ist deaktiviert. Das bestätigte externe Backup ist deshalb vor Bootloader- und Partitionsarbeiten besonders wichtig.
2. Die bestehende EFI-Systempartition liegt auf Windows-Datenträger 0; der freie Ubuntu-Bereich liegt auf Datenträger 3. Keine EFI-Partition eigenmächtig formatieren.
3. Die externen Datenlaufwerke `I:` und `J:` enthalten geschützte Nutzdaten. Nach dem vollständigen Herunterfahren von Windows sollten sie vor der Ubuntu-Installation physisch getrennt werden, damit sie im Installer nicht versehentlich als Ziel erscheinen.
4. Secure Boot ist aktiv. Auswirkungen auf spätere ROCm-/Treiberkomponenten werden erst in der dafür vorgesehenen Linux-Phase geprüft.
5. Chatterbox 0.1.7 pinnt unter Python 3.12 Torch/Torchaudio 2.6.0, während der geplante AMD-Pfad 2.9.1/2.9.0 verwendet. Dieser Konflikt bleibt **NOCH OFFEN** und muss ohne ungeplanten Paketwechsel untersucht werden.
6. Die TTS-App soll später offline funktionieren. Codex selbst benötigt dagegen eine Netzwerkverbindung zu OpenAI und ist kein Offline-Bestandteil der App.

## Fortsetzung unter Ubuntu

1. Nach der manuellen Ubuntu-Installation Ubuntu starten.
2. Die Windows-NTFS-Partition mit dem bisherigen Projekt über die Dateiverwaltung öffnen. Keine Gerätebezeichnung wie `/dev/nvme...` raten; zuerst mit der Dateiverwaltung oder `lsblk -f` eindeutig identifizieren.
3. Diesen Projektordner in einen lokalen Ubuntu-Projektordner kopieren oder kontrolliert von der NTFS-Partition öffnen.
4. [POST_UBUNTU_CODEX_SETUP.md](POST_UBUNTU_CODEX_SETUP.md) lesen.
5. Vor dem dort beschriebenen Codex-Download erneut Version, Größe, vorhandene Installation und Budget prüfen und die Download-Freigabe einholen.
6. Codex installieren, mit ChatGPT anmelden und im Projektordner starten.
7. `PROJECT_STATUS.md`, `DOWNLOAD_BUDGET.md` und dieses Dokument einlesen.
8. Nicht zu W0 zurückkehren und Ubuntu, ISO oder Rufus nicht erneut herunterladen.

Nach dem Betriebssystemwechsel ist die vorgesehene Workflowphase **U1 – Codex unter Ubuntu**. Danach folgt **U2 – nativer Hardware-Preflight**. ROCm wird erst in seiner eigenen freigegebenen Phase installiert.

## Aktueller Übergabepunkt

W7 ist abgeschlossen. Der Benutzer hat W8 und das sichere Herunterfahren für die Ubuntu-Installation ausdrücklich freigegeben. Wegen der noch belegten externen Datenlaufwerke wird Windows geordnet heruntergefahren statt direkt neu gestartet.

Wenn der Rechner vollständig ausgeschaltet ist:

1. Die geschützten externen Datenlaufwerke `I:` und `J:` physisch trennen.
2. Den Intenso-Ubuntu-Stick angeschlossen lassen.
3. Den Rechner manuell einschalten und über das UEFI-Bootmenü vom Intenso-Stick starten.
4. In U0 nur „Ubuntu neben Windows Boot Manager installieren“ wählen. Falls diese Option fehlt: **STOPP** und einen Screenshot oder ein Foto bereitstellen.
