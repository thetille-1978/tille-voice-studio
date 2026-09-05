# Tille Voice Studio – Windows-Preflight (Phase W0)

- Erfasst am: 2026-09-05, 03:35 Uhr (Europe/Berlin)
- Arbeitsweise: ausschließlich lesende lokale Diagnosebefehle
- Downloads: 0 GB
- Systemänderungen: keine

## Ergebnisübersicht

Der Rechner ist grundsätzlich ein geeigneter Kandidat für das geplante native Ubuntu-/ROCm-System: Windows startet im UEFI-Modus, alle erkannten Datenträger verwenden GPT und die AMD Radeon RX 7700 XT wird mit 12 GB VRAM fehlerfrei erkannt. Aktuell gibt es jedoch auf keinem Datenträger nicht zugeordneten Speicher.

Als voraussichtlich beste Zielpartition für eine spätere Verkleinerung bietet sich `A:` auf der internen Kingston-NVMe (Datenträger 3) an. Dort sind 220,16 GiB innerhalb des NTFS-Dateisystems frei. Eine spätere Verkleinerung um ungefähr 100 GiB würde rechnerisch rund 120 GiB freien Platz in `A:` belassen. Das ist nur eine Empfehlung; in W0 wurde nichts verkleinert oder anderweitig verändert.

Die anschließend vom Benutzer in einer erhöhten PowerShell ausgeführten Prüfungen bestätigen: Alle erkannten Windows-Volumes sind vollständig entschlüsselt, der BitLocker-Schutz ist ausgeschaltet und es wird keine Verschlüsselungsmethode verwendet. Windows RE ist deaktiviert und besitzt derzeit keinen registrierten Speicherort. Damit sind alle W0-Prüfpunkte abgeschlossen.

## Windows und Plattform

| Merkmal | Ergebnis |
|---|---|
| Betriebssystem | Microsoft Windows 11 Home |
| Version | 25H2 |
| Build | 26200.9278 |
| Architektur | 64-Bit, x64-basierter PC |
| CPU | AMD Ryzen 5 7500F, 6 Kerne / 12 logische Prozessoren |
| Installierter RAM | 31,65 GiB |
| BIOS | American Megatrends Inc., Version 3057 vom 2024-10-29 |
| Firmware-/Bootmodus | UEFI |
| Partitionsstil | GPT auf allen sechs erkannten Datenträgern |
| Secure Boot | Aktiviert (`UEFISecureBootEnabled = 1`) |

Hinweis: Der ältere Registry-Wert `ProductName` meldet weiterhin „Windows 10 Home“. Die aktuelle Betriebssystemabfrage meldet eindeutig Windows 11 Home, Version 25H2, Build 26200.9278; der alte Registry-Text ist bei aktualisierten Windows-Installationen möglich und wurde nicht als maßgeblich verwendet.

## GPU

| Merkmal | Ergebnis |
|---|---|
| GPU | AMD Radeon RX 7700 XT |
| Gerätestatus | OK |
| VRAM | 12 GB (12.868.124.672 Byte, etwa 11,98 GiB) |
| Windows-Treiberversion | 32.0.31021.5001 |
| Treiberdatum | 2026-06-28 |
| PCI-Kennung | `PCI\\VEN_1002&DEV_747E&SUBSYS_24141458` |
| Linux-Zielarchitektur | `gfx1101` (vom Projekt vorgegeben; unter Linux/ROCm später nativ zu verifizieren) |

Die standardmäßige WMI-Eigenschaft `AdapterRAM` ist auf diesem System auf ungefähr 4 GB abgeschnitten. Für den Bericht wurde deshalb der 64-Bit-Wert `HardwareInformation.qwMemorySize` aus dem AMD-Geräteeintrag verwendet.

## Boot-, Verschlüsselungs- und Recovery-Status

| Prüfung | Ergebnis |
|---|---|
| UEFI | Bestätigt |
| GPT | Bestätigt, alle Datenträger |
| Secure Boot | Aktiviert, per lesbarem Secure-Boot-Registryzustand bestätigt |
| BitLocker/Geräteverschlüsselung | Aus auf allen gemeldeten Volumes (`A:`, `C:` bis `J:`); vollständig entschlüsselt, 0 %, Methode `None`, Status `Unlocked` |
| Windows Recovery Environment | Deaktiviert; kein registrierter Windows-RE-Ort; gemeldete Version `0.0.0.0` |
| Windows-Schnellstart | Registrywert aktiviert (`HiberbootEnabled = 1`), derzeit aber laut `powercfg /a` nicht verfügbar, weil der Ruhezustand deaktiviert ist |

Die 0,70-GiB-Partition `H:` auf Datenträger 0 enthält einen Ordner `Recovery` und die Datei `$WINRE_BACKUP_PARTITION.MARKER`. Sie ist daher sehr wahrscheinlich ein früherer oder vorbereiteter Recovery-Bereich. Windows meldet sie allerdings als normale GPT-Basic-Data-Partition mit Laufwerksbuchstaben, und `reagentc /info` bestätigt, dass sie derzeit nicht als aktive Windows-RE-Umgebung registriert ist. Sie darf trotzdem nicht gelöscht, formatiert oder für Ubuntu verwendet werden.

## Physische Datenträger und Partitionen

Alle Datenträger meldeten den Zustand „Healthy/Online“. Größen und freie Werte sind in GiB angegeben.

### Datenträger 0 – Samsung SSD 870 EVO 1TB (SATA)

- Größe: 931,51 GiB
- GPT, Windows-Boot- und Systemdatenträger
- Nicht zugeordnet: 0 GiB
- Partition 1, `C:`: 388,24 GiB NTFS, 12,26 GiB frei, Windows-Bootpartition
- Partition 2, `H:`: 0,70 GiB NTFS, 0,07 GiB frei, Recovery-Inhalte vorhanden
- Partition 3, `G:` (`Volume`): 542,28 GiB NTFS, 24,76 GiB frei
- Partition 4: 0,29 GiB, versteckte EFI-Systempartition, GPT-Typ `c12a7328-f81f-11d2-ba4b-00a0c93ec93b`

### Datenträger 1 – TOSHIBA MQ01ABD100 (SATA)

- Größe: 931,51 GiB
- GPT
- Nicht zugeordnet: 0 GiB
- Partition 1, `E:` (`Datenbank`): 931,51 GiB NTFS, 100,92 GiB frei

### Datenträger 2 – WDC WD5000AAKX-001CA0 (SATA)

- Größe: 465,76 GiB
- GPT
- Nicht zugeordnet: 0 GiB
- Partition 1, `D:` (`System Reserved`): 0,10 GiB NTFS, 0,07 GiB frei; enthält ältere Bootdateien, ist aber laut Windows nicht die aktuelle Systempartition
- Partition 2, `F:` (`Programme`): 465,66 GiB NTFS, 44,82 GiB frei

### Datenträger 3 – KINGSTON SNV3S1000G (NVMe)

- Größe: 931,51 GiB
- GPT
- Nicht zugeordnet: 0 GiB
- Partition 1, `A:` (`Mainbord M2`): 931,51 GiB NTFS, 220,16 GiB frei
- **Empfohlener späterer Kandidat:** Verkleinerung von `A:` um etwa 100 GiB, ausschließlich nach Backup, erneuter Prüfung und ausdrücklicher Systemänderungs-Freigabe in Phase W5

### Datenträger 4 – WD Elements 25A3 (USB)

- Größe: 3.725,99 GiB
- GPT
- Partition 1, `I:` (`Elements`): 3.725,99 GiB NTFS, 1.211,63 GiB frei
- Externer Datenträger mit vorhandenen Daten; nicht als Ubuntu-Installationsstick behandeln

### Datenträger 5 – Seagate PS4 Game Drive (USB)

- Größe: 1.863,02 GiB
- GPT
- Partition 1, `J:` (`Native Instruments`): 1.863,01 GiB NTFS, 1.277,44 GiB frei
- Externer Datenträger mit vorhandenen Daten; nicht als Ubuntu-Installationsstick behandeln

## Nicht zugeordneter und freier Speicher

- Nicht zugeordneter Speicher: 0 GiB auf allen erkannten Datenträgern
- Empfohlenes Ubuntu-Ziel: ungefähr 100 GiB
- Projektminimum: ungefähr 60 GiB
- Sinnvollster späterer Kandidat: `A:` auf Datenträger 3, da interne NVMe und 220,16 GiB Dateisystemfreiraum
- `E:` besitzt mit 100,92 GiB zwar rechnerisch genug freien Platz für das Minimum, bietet bei einer 100-GiB-Verkleinerung aber praktisch keinen verbleibenden Puffer und liegt auf einer langsameren SATA-Festplatte
- Die tatsächlich von Windows verkleinerbare Größe kann wegen unbeweglicher NTFS-Dateien kleiner als der angezeigte freie Speicher sein. Das ist erst in Phase W5 zu prüfen.

## Ubuntu-ISO, Rufus und USB-Geräte

- Ubuntu-ISO: keine Datei mit dem Muster `*ubuntu*.iso` in den geprüften Bereichen gefunden
- Rufus: weder als installierte Anwendung noch als `rufus*.exe` in den geprüften Bereichen gefunden
- Geprüfte Bereiche: `C:\Users\Tille\Downloads`, `C:\Users\Tille\Desktop`, `A:\OneDrive\Documents`
- Angeschlossene USB-Datenträger: WD Elements 25A3 (`I:`) und Seagate PS4 Game Drive (`J:`)
- Es wurde kein kleiner, eindeutig als leerer Installations-USB-Stick erkennbarer Datenträger gefunden

Die Suche war bewusst auf typische Speicherorte und den Projekt-/Dokumentenbereich beschränkt. Es wurde keine aggressive Vollsuche über sämtliche externen Datenträger durchgeführt.

## Bestehende Virtualisierung

- Oracle VirtualBox 7.2.14 erkannt
- Registrierte VMs: `Ti Mac`, `kali-linux-2026.2-virtualbox-amd64`, `Asterisk`
- VMware wurde in den geprüften Installations- und Diensteinträgen nicht erkannt
- Keine VM wurde gestartet, geöffnet, verändert, verschoben oder umkonfiguriert

## Risiken und Empfehlungen

1. **Windows RE ist deaktiviert.** Damit steht aktuell keine registrierte lokale Windows-Wiederherstellungsumgebung zur Verfügung. Vor Partitions- oder Bootloaderarbeiten sind deshalb ein aktuelles Backup und ein separat geprüftes Windows-Wiederherstellungs-/Installationsmedium besonders wichtig. In W0 wird Windows RE nicht verändert.
2. **`H:` enthält Recovery-Reste, ist aber nicht als Windows RE registriert.** Die Partition ist ungewöhnlich typisiert und sichtbar; sie trotzdem nicht anfassen.
3. **Kein nicht zugeordneter Speicher vorhanden.** Eine spätere Windows-Partition muss erst nach ausdrücklicher Freigabe verkleinert werden.
4. **`C:` hat nur 12,26 GiB frei.** Das ist knapp für Windows-Updates und ungeeignet als Ubuntu-Ziel oder Ablage großer Projektpakete.
5. **EFI liegt auf Datenträger 0, das empfohlene Ubuntu-Ziel auf Datenträger 3.** Die spätere EFI-/Bootloaderstrategie muss vor der Installation eindeutig festgelegt werden; keinesfalls vorhandene EFI- oder Bootpartitionen löschen.
6. **Schnellstart ist widersprüchlich konfiguriert.** Er ist in der Registry eingeschaltet, aber wegen deaktiviertem Ruhezustand derzeit nicht nutzbar. Vor Dual-Boot in Phase W4 erneut prüfen.
7. **Externe USB-Datenträger enthalten offenbar Nutzdaten.** `I:` und `J:` niemals ohne eindeutige Einzelbestätigung als Installationsmedium verwenden.
8. **Vor einer späteren Verkleinerung von `A:`** OneDrive-Synchronisierung, Backup, Dateisystemzustand und tatsächlich verkleinerbaren Bereich prüfen.

## Ergebnis der Administratornachprüfung

- `Get-BitLockerVolume`: Alle gemeldeten Volumes (`A:`, `C:`, `D:`, `E:`, `F:`, `G:`, `H:`, `I:`, `J:`) sind `FullyDecrypted`, `ProtectionStatus Off`, `EncryptionMethod None`, `EncryptionPercentage 0` und `Unlocked`.
- `reagentc /info`: `Windows RE-Status: Disabled`; Windows-RE-Ort leer; Wiederherstellungs- und benutzerdefinierte Images nicht registriert; gemeldete Windows-RE-Version `0.0.0.0`.
- Die Ausgabe wurde am 2026-09-05 vom Benutzer aus einer als Administrator gestarteten PowerShell bereitgestellt.

## Checkpoint W0

Status: **PASS**

Erfolgreich:

- Windows-Version, Architektur, CPU und RAM erfasst
- RX 7700 XT und 12 GB VRAM erkannt
- UEFI, GPT und Secure Boot bestätigt
- Alle physischen Datenträger, Partitionen und freien Bereiche erfasst
- EFI-Partition erkannt
- Recovery-bezogene Partition erkannt und geschützt markiert
- BitLocker-/Geräteverschlüsselungsstatus für alle gemeldeten Volumes bestätigt
- Windows-RE-Status und fehlende aktive Zuordnung bestätigt
- USB-Datenträger, Rufus-/ISO-Status und vorhandene VirtualBox-Installation geprüft
- Keine Downloads und keine Systemänderungen durchgeführt

Problem:

- Kein W0-blockierendes Diagnoseproblem mehr offen.
- Windows RE ist deaktiviert; das ist als Sicherheitsrisiko für spätere Systemarbeiten dokumentiert, wird aber in W0 nicht verändert.

Nächster vorgesehener Schritt ist Phase W1: reine Ubuntu-/ROCm-Kompatibilitätsrecherche. Phase W1 wurde noch nicht begonnen und benötigt die ausdrückliche Freigabe des Benutzers.
