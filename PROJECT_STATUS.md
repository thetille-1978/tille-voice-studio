# Projektstatus – Tille Voice Studio

Stand: 2026-09-05, Phase W6 – PASS

| Bereich | Status |
|---|---|
| System | Windows 11 Home 25H2, Build 26200.9278, x64; W4-Sicherheitsprüfung durchgeführt |
| Ubuntu | ISO 24.04.4 LTS Desktop AMD64 vollständig geladen und SHA256-verifiziert; noch nicht installiert |
| Rufus | Portable x64 4.15.2396 geladen; Authenticode gültig; noch nicht gestartet |
| Kernel | Plan verifiziert: Ubuntu 6.17 HWE; noch nicht installiert |
| GPU | AMD Radeon RX 7700 XT, 12 GB VRAM, Windows-Status OK |
| gfx | `gfx1101` laut AMD verifiziert; unter installiertem Linux später praktisch zu bestätigen |
| ROCm | Plan: 7.2.1 Radeon-Produktionspfad; noch nicht installiert |
| Python | Plan: 3.12; noch nicht installiert/geprüft |
| PyTorch | Plan: 2.9.1 + ROCm 7.2.1; noch nicht installiert |
| Torchaudio | Plan: 2.9.0 + ROCm 7.2.1; noch nicht installiert |
| Torchvision | Plan: 0.24.0 + ROCm 7.2.1; noch nicht installiert |
| Triton | Plan: 3.5.1 + ROCm 7.2.1; noch nicht installiert |
| Chatterbox | 0.1.7 / Multilingual V3; Torch-2.6-Pin-Konflikt NOCH OFFEN |
| Modell | Chatterbox Multilingual V3, 500M; noch nicht heruntergeladen |
| GUI | noch nicht begonnen |
| Downloadverbrauch | 6,658 GB / 20 GB; 13,342 GB verbleibend |
| SSD-Verbrauch Projekt | 6,658 GB ISO/Rufus außerhalb OneDrive plus unter 0,01 GB Projektdokumentation/Git-Metadaten |

## Checkpoints

- [x] Windows Preflight – PASS; BitLocker aus, alle Volumes entschlüsselt, Windows RE deaktiviert
- [x] Kompatibilitätsplan W1 – PASS; Basisstack verifiziert, Chatterbox-Pin-Konflikt dokumentiert
- [x] Ubuntu ISO – PASS; 6.655.619.072 Byte, offizielle SHA256 bestätigt
- [x] Boot-USB-Werkzeug W3 – PASS; Rufus 4.15.2396, gültige Authenticode-Signatur
- [x] Windows-Dual-Boot-Vorbereitung W4 – PASS; Backup vom Benutzer bestätigt
- [x] Ubuntu-Platz W5 – PASS; `A:` exakt um 100 GiB verkleinert, 100,001 GiB nicht zugeordnet
- [x] Ubuntu-Installationsmedium W6 – PASS; Intenso-Stick mit Ubuntu 24.04.4 im GPT-/UEFI-Modus erstellt und lesend verifiziert
- [ ] Dual Boot
- [ ] Ubuntu nativ
- [ ] RX 7700 XT erkannt
- [ ] ROCm
- [ ] PyTorch GPU
- [ ] Chatterbox
- [ ] Voice Clone
- [ ] GUI
- [ ] Long Text
- [ ] WAV
- [ ] MP3
- [ ] Offline Test
- [ ] Final Test

## Letzter Stand

- Ubuntu-ISO in Phase W2 nach ausdrücklicher Einzel-Freigabe fortsetzbar heruntergeladen.
- Bis einschließlich W4 wurden keine Systemänderungen durchgeführt; in W5 wurde die ausdrücklich freigegebene Partitionsverkleinerung vorgenommen.
- Keine vorhandene VM verändert.
- W0 erfolgreich abgeschlossen.
- BitLocker/Geräteverschlüsselung ist auf allen gemeldeten Volumes aus; alle sind vollständig entschlüsselt.
- Windows RE ist deaktiviert und besitzt keinen registrierten Speicherort.
- W1 erfolgreich abgeschlossen; `docs/COMPATIBILITY_PLAN.md` enthält die offizielle Quellenmatrix.
- Aktuelles Ziel: Ubuntu 24.04.4, Kernel 6.17 HWE, ROCm 7.2.1, Python 3.12 und PyTorch 2.9.1.
- Chatterbox 0.1.7 verlangt unter Python 3.12 noch Torch/Torchaudio 2.6.0; kontrollierte Kompatibilitätsprüfung ist vor Installation zwingend.
- W2 erfolgreich abgeschlossen: `A:\TilleVoiceStudioDownloads\downloads\ubuntu-24.04.4-desktop-amd64.iso`, 6.655.619.072 Byte.
- Lokale SHA256: `3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e`; stimmt exakt mit `SHA256SUMS` von Ubuntu überein.
- W3 erfolgreich abgeschlossen: `A:\TilleVoiceStudioDownloads\downloads\rufus-4.15p.exe`, Version 4.15.2396, 1.989.992 Byte.
- Rufus-SHA256: `84c8a437f8af89257524478489e5c85f1edf25f761d299e2bcde46ac0afbe106`; Authenticode-Status **Valid**, Signierer Akeo Consulting.
- Rufus wurde nicht gestartet und kein USB-Datenträger wurde verändert.
- W4-Liveprüfung: Schnellstart ist in der Registry mit `HiberbootEnabled=1` vorgemerkt, aber wegen deaktiviertem Ruhezustand derzeit nicht verfügbar; `C:\hiberfil.sys` ist nicht vorhanden.
- W4-Speicherprüfung: `A:` auf der internen Kingston-NVMe besitzt aktuell 213,96 GiB freien Dateisystemplatz. Rechnerisch sind 100 GiB für Ubuntu möglich; die tatsächlich verkleinerbare Größe wird erst in W5 geprüft.
- Laut der bereits vom Benutzer erhöht ausgeführten BitLocker-Prüfung sind alle gemeldeten Volumes vollständig entschlüsselt und der Schutz ist aus. Ein Recovery-Key ist für den aktuellen unverschlüsselten Zustand nicht erforderlich.
- Windows RE ist weiterhin als deaktiviert dokumentiert; dadurch ist ein verifiziertes Backup vor Partitionsarbeiten besonders wichtig.
- W4-Backupanforderung erfüllt: Der Benutzer hat ausdrücklich bestätigt, dass wichtige Daten gesichert und wiederherstellbar sind.
- Keine Einstellungen, Partitionen, Bootdaten oder USB-Datenträger wurden verändert.
- W4 erfolgreich abgeschlossen. Nächster vorgesehener Schritt nur nach ausdrücklicher Freigabe: Phase W5, tatsächlich verkleinerbaren Bereich von `A:` prüfen und vor jeder Partitionsänderung eine separate SYSTEMÄNDERUNGS-FREIGABE einholen.
- W5-Vorprüfung: Datenträger 3, KINGSTON SNV3S1000G, GPT, Partition 1 `A:`, 931,511 GiB groß und 213,962 GiB frei; Windows erlaubte maximal 182,320 GiB Verkleinerung.
- Freigegebene W5-Systemänderung ausgeführt: `A:` wurde mit dem Windows-Storage-Cmdlet, ohne `diskpart`, exakt um 107.374.182.400 Byte beziehungsweise 100 GiB verkleinert.
- Verifizierter Endzustand: `A:` ist 831,511 GiB groß und besitzt 113,966 GiB freien Dateisystemplatz; Datenträger 3 besitzt 100,001 GiB nicht zugeordneten Speicher.
- `A:` meldet nach der Verkleinerung weiterhin den Zustand **Healthy**. Projektdateien, Ubuntu-ISO und Rufus sind vollständig erreichbar.
- Der neue Bereich wurde nicht formatiert und keinem Laufwerksbuchstaben zugeordnet. EFI-, MSR-, Recovery-, Boot- und andere Partitionen wurden nicht verändert.
- W5 erfolgreich abgeschlossen. Nächster vorgesehener Schritt nur nach ausdrücklicher Freigabe: Phase W6, einen geeigneten USB-Stick eindeutig identifizieren und vor dem Löschen eine separate USB-LÖSCHBESTÄTIGUNG einholen.
- W6-Erstinventur vom 2026-09-05 04:53 Uhr: Zwei große USB-Datenträger erkannt; beide sind online und fehlerfrei, enthalten aber vorhandene NTFS-Daten.
- Datenträger 4: WD Elements 25A3, Seriennummer `WCC7K3CYK7NC`, 3.725,991 GiB, Volume `I:` / `Elements`, 1.211,633 GiB frei. **Nicht als Installationsmedium verwenden.**
- Datenträger 5: Seagate PS4 Game Drive, Seriennummer `NZ0MSQ12`, 1.863,017 GiB, Volume `J:` / `Native Instruments`, 1.277,444 GiB frei. **Nicht als Installationsmedium verwenden.**
- Nachträglich erkannter Kandidat, Datenträger 6: WD Elements 1078, Seriennummer `WX81A75EZYCF`, USB, MBR, 931,481 GiB, eine NTFS-Partition `K:` / `Backup HD Games`, 742,251 GiB frei und damit rund 189 GiB belegt.
- Rufus blendet externe USB-HDDs aus Sicherheitsgründen standardmäßig aus und bezeichnet ihre Formatierung als nicht offiziell unterstützt. Die Nutzung von `K:` wäre technisch möglich, würde aber den gesamten physischen Datenträger 6 einschließlich aller vorhandenen Daten löschen.
- Der Benutzer hat bestätigt, dass das Backup von `K:` vollständig ist, und die vollständige Löschung von Datenträger 6 – WD Elements 1078, Seriennummer `WX81A75EZYCF` – ausdrücklich freigegeben.
- Die frühere Löschfreigabe galt ausschließlich für den inzwischen nicht mehr angeschlossenen Datenträger WD Elements 1078, Seriennummer `WX81A75EZYCF`. Sie gilt nicht für ein anderes Gerät, auch wenn dieses ebenfalls den Laufwerksbuchstaben `K:` erhält.
- W6-Neuinventur: Datenträger 6 ist jetzt ein **Intenso Rainbow Line** USB-Stick, Seriennummer `AA00000000000485`, 15.623.782.400 Byte / 14,551 GiB, MBR, `K:` / Volume `TILLE`, FAT32, 14,534 GiB frei, `Removable Media`, Healthy/Online.
- Die geschützten Datenlaufwerke `I:` (`Elements`) und `J:` (`Native Instruments`) sind weiterhin angeschlossen. Sie können angeschlossen bleiben, weil Windows sie als externe Festplatten klassifiziert und Rufus diese standardmäßig ausblendet. Rufus' Option **„USB-Festplatten anzeigen“** darf nicht aktiviert werden; falls `I:` oder `J:` dennoch in Rufus erscheinen, ist sofort zu stoppen.
- Der Benutzer hat anschließend die vollständige Löschung ausschließlich von Datenträger 6 / Intenso Rainbow Line / Seriennummer `AA00000000000485` ausdrücklich bestätigt.
- Unmittelbare Vorstartprüfung bestanden: Datenträgernummer, Modell, Seriennummer, Größe 15.623.782.400 Byte und Laufwerksbuchstabe `K:` stimmen exakt; Ubuntu-ISO und Rufus besitzen weiterhin die erwarteten Dateigrößen.
- Rufus 4.15p wurde sichtbar gestartet und reagiert. Eine Formatierung wurde noch nicht ausgelöst; vor **START** müssen Zielgerät, ISO, GPT/UEFI und die deaktivierte Anzeige von USB-Festplatten kontrolliert werden.
- Rufus meldete den Schreibvorgang anschließend als **FERTIG**. Die sichtbaren Einstellungen waren: Ziel `TILLE (K:) [16 GB]`, Ubuntu-24.04.4-ISO, keine Persistenz, GPT, UEFI ohne CSM, FAT32 und Standard-Zuordnungseinheit.
- Nachprüfung des physischen Zielgeräts bestanden: Datenträger 6 ist weiterhin Intenso Rainbow Line, Seriennummer `AA00000000000485`, 14,551 GiB, Healthy/Online und nun GPT.
- Das erstellte Volume `K:` heißt `UBUNTU 24_0`, verwendet FAT32, ist 14,55 GiB groß und enthält die erwarteten Ubuntu-/UEFI-Strukturen `.disk`, `boot`, `casper`, `EFI\\BOOT` und `boot\\grub`.
- Die geschützten Datenträger `I:` und `J:` wurden nicht ausgewählt oder verändert. W6 ist **PASS**.
- Nächster vorgesehener Schritt nur nach ausdrücklicher Freigabe: Phase W7 – Übergabe vor Neustart und vollständige Readiness-Checkliste. Noch kein Neustart.
