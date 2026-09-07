# Projektstatus – Tille Voice Studio

Stand: 2026-09-07, Phase U3B – PASS / U3C-PLANUNG OFFEN

| Bereich | Status |
|---|---|
| System | Ubuntu 24.04.4 LTS nativ auf x86_64; Dual Boot mit Windows bestätigt |
| Ubuntu | 24.04.4 LTS erfolgreich nativ gestartet; U0 PASS |
| Rufus | Portable x64 4.15.2396; Authenticode gültig; Ubuntu-Stick in W6 erfolgreich erstellt |
| Kernel | 6.17.0-14-generic aktiv und dauerhaftes GRUB-Ziel; U3K PASS |
| GPU | AMD Radeon RX 7700 XT, PCI-ID `1002:747e`, 12.272 MiB VRAM; `amdgpu` und KFD aktiv |
| gfx | `gfx1101` nativ bestätigt (`gfx_target_version 110001`) |
| ROCm | PASS – 7.2.1 vollständig installiert; signiertes AMD-DKMS 6.16.13 unter Kernel 6.17 aktiv; `gfx1101` und OpenCL verifiziert |
| Python | System-Python 3.12.3 vorhanden; noch keine Projektumgebung eingerichtet |
| PyTorch | Plan: 2.9.1 + ROCm 7.2.1; noch nicht installiert |
| Torchaudio | Plan: 2.9.0 + ROCm 7.2.1; noch nicht installiert |
| Torchvision | Plan: 0.24.0 + ROCm 7.2.1; noch nicht installiert |
| Triton | Plan: 3.5.1 + ROCm 7.2.1; noch nicht installiert |
| Chatterbox | 0.1.7 / Multilingual V3; Torch-2.6-Pin-Konflikt NOCH OFFEN |
| Modell | Chatterbox Multilingual V3, 500M; noch nicht heruntergeladen |
| GUI | noch nicht begonnen |
| Codex unter Ubuntu | U1 PASS; gebündelte Codex CLI 0.153.4 unter `/usr/lib/chatgpt/resources/codex` verfügbar; Standalone nicht heruntergeladen |
| Downloadverbrauch | ca. 13,567 GB / 20 GB tatsächlich; ca. 6,433 GB verbleibend, davon 0,250 GB für Codex reserviert |
| SSD-Verbrauch Projekt | 6,658 GB ISO/Rufus außerhalb OneDrive plus unter 0,01 GB Projektdokumentation |

## Checkpoints

- [x] Windows Preflight – PASS; BitLocker aus, alle Volumes entschlüsselt, Windows RE deaktiviert
- [x] Kompatibilitätsplan W1 – PASS; Basisstack verifiziert, Chatterbox-Pin-Konflikt dokumentiert
- [x] Ubuntu ISO – PASS; 6.655.619.072 Byte, offizielle SHA256 bestätigt
- [x] Boot-USB-Werkzeug W3 – PASS; Rufus 4.15.2396, gültige Authenticode-Signatur
- [x] Windows-Dual-Boot-Vorbereitung W4 – PASS; Backup vom Benutzer bestätigt
- [x] Ubuntu-Platz W5 – PASS; `A:` exakt um 100 GiB verkleinert, 100,001 GiB nicht zugeordnet
- [x] Ubuntu-Installationsmedium W6 – PASS; Intenso-Stick mit Ubuntu 24.04.4 im GPT-/UEFI-Modus erstellt und lesend verifiziert
- [x] Übergabe vor Neustart W7 – PASS; Readiness vollständig, Übergabe- und Codex-Setup-Dokumente erstellt
- [x] Manueller Betriebssystemwechsel W8 – PASS; geordneter Shutdown ausgeführt und Ubuntu-Installer gestartet
- [x] Ubuntu-Installation U0 – PASS; installiertes Ubuntu 24.04.4 nativ gestartet
- [x] Dual Boot – Windows- und Ubuntu-Start bestätigt
- [x] Codex unter Ubuntu U1 – PASS; Projektordner und Übergabedokumente geladen
- [x] Nativer Hardware-Preflight U2 – PASS; Details in `docs/U2_NATIVE_HARDWARE_PREFLIGHT.md`
- [x] U3A – AMD-Repository-Bootstrap, APT-Metadaten und Nur-Lese-Installationssimulation – PASS
- [x] U3K – Kernel 6.17 dauerhaftes GRUB-Bootziel; Änderung und Neustartprüfung PASS
- [x] U3B – ROCm-Systemstack, DKMS-Reparatur, MOK und Benutzerterminal-Postflight – PASS
- [x] Ubuntu nativ – PASS
- [x] RX 7700 XT erkannt – PASS
- [x] ROCm – PASS
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
- Rufus war zum Abschluss von W3 noch nicht gestartet; in W6 wurde damit ausschließlich der freigegebene Intenso-Stick beschrieben.
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
- W7-Liveprüfung vom 2026-09-05: ISO-SHA256 erneut exakt bestätigt; Intenso-Stick weiterhin Healthy/GPT/FAT32 mit EFI-, GRUB- und Ubuntu-Inhalten; 100,001 GiB auf Datenträger 3 weiterhin nicht zugeordnet.
- UEFI, Secure Boot und RX 7700 XT sind weiterhin bestätigt. Schnellstart ist trotz latentem Registrywert funktional inaktiv, weil Ruhezustand und `C:\hiberfil.sys` fehlen.
- `CODEX_CONTINUE_AFTER_UBUNTU.md` und `POST_UBUNTU_CODEX_SETUP.md` erstellt. Aktueller offizieller Codex-Linux-Pfad ist der Standalone-Installer; Node.js/npm ist für den bevorzugten Weg nicht erforderlich.
- Für die spätere Codex-CLI-Installation wurden konservativ 0,250 GB reserviert. Tatsächlicher Download in W7: 0 GB.
- **UBUNTU INSTALLATION READY.** W7 ist **PASS**.
- Der Benutzer hat W8, den Betriebssystemwechsel und ein sicheres Herunterfahren ausdrücklich freigegeben.
- Wegen der noch durch Prozesse belegten Datenlaufwerke `I:` und `J:` wird ein geordneter Windows-Shutdown ohne `/f` verwendet. Nach vollständigem Ausschalten müssen `I:` und `J:` physisch getrennt werden; der Intenso-Ubuntu-Stick bleibt angeschlossen.
- Nach dem manuellen Einschalten folgt U0 – manuelle Ubuntu-Installation. Wenn „Ubuntu neben Windows Boot Manager installieren“ nicht angeboten wird: **STOPP**, keine Partitionierung raten und Screenshot/Foto bereitstellen.
- Der Benutzer hat Ubuntu 24.04.4 vom verifizierten Stick mit Standardeinstellungen und zunächst ohne Internet installiert, neu gestartet, den Installationsstick entfernt und anschließend Windows erfolgreich gebootet.
- Windows-Nachprüfung nach U0: Datenträger 3 / KINGSTON SNV3S1000G bleibt Healthy/GPT. `A:` ist unverändert 831,511 GiB groß.
- Der frühere freie Bereich wurde vom Ubuntu-Installer in eine 1,05-GiB-EFI-Systempartition (GPT-Typ `c12a7328-f81f-11d2-ba4b-00a0c93ec93b`) und eine 98,95-GiB-Linux-Dateisystempartition (GPT-Typ `0fc63daf-8483-4772-8e79-3d69d8477de4`) aufgeteilt.
- Nur noch rund 0,001 GiB sind nicht zugeordnet. Die Partitionsgrößen entsprechen dem vorgesehenen Ubuntu-Bereich; vorhandene Windows-Volumes sind weiterhin erreichbar.
- Der Intenso-Installationsstick ist entfernt. Die geschützten USB-Datenlaufwerke `I:` und `J:` werden weiterhin als Healthy erkannt.
- U0 nachträglich abgeschlossen: Das installierte Ubuntu 24.04.4 wurde erfolgreich nativ gestartet; `/boot/efi` liegt auf der neuen 1-GiB-EFI-Partition und `/` auf der 99-GiB-ext4-Partition der KINGSTON-NVMe.
- U1 abgeschlossen: Codex ist unter Ubuntu verfügbar, im lokalen Projektpfad gestartet und hat die Übergabedokumente eingelesen. Die vorhandene gebündelte Codex CLI meldet Version 0.153.4; dafür entstand kein neuer Projekt-Download.
- U2-Liveprüfung vom 2026-09-06: Ubuntu 24.04.4, Kernel 6.17.0-14-generic, x86_64, UEFI und Secure Boot bestätigt.
- Die RX 7700 XT wird nativ als PCI-Gerät `1002:747e` erkannt. `amdgpu` ist geladen, KFD hat einen dGPU-Knoten angelegt, 12.272 MiB VRAM sind bereit und `gfx_target_version 110001` bestätigt `gfx1101`.
- Benutzerseitiger Terminaltest nach der Zugriffsbereinigung: `/dev/kfd` und `/dev/dri/renderD128` sind für den Benutzer beide les- und schreibbar. Der anfängliche KFD-Berechtigungsblocker ist behoben.
- CPU AMD Ryzen 5 7500F (6 Kerne/12 Threads), 30 GiB RAM, 8 GiB Swap und 75 GiB freier Platz auf `/` bestätigt.
- ROCm-, AMD-SMI- und `rocminfo`-Werkzeuge sind noch nicht installiert; das ist am Ende von U2 erwartungsgemäß. U2 verursachte keinen Download.
- U2 ist **PASS**. Nächster Schritt ist die separat zu planende ROCm-Phase. Vor Paketinstallation oder Download müssen die dann aktuelle offizielle AMD-Methode, genaue Komponenten, Downloadgrößen, Secure-Boot-Auswirkungen und das Budget geprüft und einzeln freigegeben werden.
- U3-Planungsprüfung vom 2026-09-06: Die aktuelle offizielle AMD-Radeon-Matrix bestätigt weiterhin Ubuntu 24.04.4/HWE 6.17, RX 7700 XT, ROCm 7.2.1 und PyTorch 2.9.1 als Produktionspfad.
- Die Radeon-spezifische AMD-Anleitung sieht `graphics,rocm` vor. Dieser Pfad kann `amdgpu-dkms` installieren und erfordert bei aktivem Secure Boot eine kontrollierte MOK-Signierung. Der vorhandene Ubuntu-`amdgpu` funktioniert bereits; deshalb wird keine Treiberänderung vor einer separaten Freigabe vorgenommen.
- Lokale U3-Vorprüfung: Kernel-Header sind vorhanden; `python3-pip`, `python3-wheel`, Setuptools, DKMS und ROCm-Pakete fehlen. Die lokalen APT-Metadaten sind unvollständig.
- Die vier offiziellen AMD-Framework-Wheels umfassen laut HTTP-Metadaten zusammen 1.941.642.484 Byte / 1,942 GB. ROCm-Systempakete und Voraussetzungen sind darin noch nicht enthalten.
- Vollständiger Plan: `docs/U3_ROCM_INSTALL_PLAN.md`. U3A erhielt vor der Repository-/APT-Änderung und dem Download die getrennte Freigabe.
- Wegen der Codex-Netzwerk-/`sudo`-Sandbox wurde der vorbereitete Helfer `scripts/u3a_prepare_and_simulate.sh` im normalen Ubuntu-Terminal ausgeführt. Er stoppte wie vorgesehen nach Repository-Bootstrap, Metadatenaktualisierung, AMD-`--dryrun`, unabhängiger APT-Simulation und Größenermittlung.
- Ein Abrufversuch innerhalb der Sandbox scheiterte bereits bei der DNS-Auflösung und erzeugte nur eine 0-Byte-Platzhalterdatei in `work/u3a`; dies verursachte keinen Downloadverbrauch. Der Helfer ersetzt sie erst nach erfolgreicher Größen- und Paketmetadatenprüfung.
- U3A wurde anschließend erfolgreich abgeschlossen. Installiert wurde ausschließlich das offizielle 16.908-Byte-Paket `amdgpu-install`; die AMD-Quellen für ROCm 7.2.1 und AMDGPU 30.30.1 sind registriert. ROCm, DKMS und Frameworks blieben unangetastet.
- Die protokollierte Referenzsimulation umfasst 444 neue Pakete, keine Entfernung und 6.855.525.228 Byte / 6,856 GB Download. Die vier AMD-Framework-Wheels kämen mit weiteren 1.941.642.484 Byte / 1,942 GB hinzu.
- U3A verursachte einschließlich APT-Metadaten ungefähr 0,0534 GB Download; der kumulierte Projektverbrauch liegt damit bei ungefähr 6,711 GB.
- Kritischer Kernelbefund: Der Neustart am 2026-09-07 hat den bereits installierten HWE-Kernel 7.0.0-31 aktiviert. Der unterstützte Kernel 6.17.0-14 ist weiterhin installiert; AMDs ROCm-7.2.1-Matrix nennt für Ubuntu 24.04.4 ausdrücklich Kernel 6.17.
- Der aktuelle offizielle Chatterbox-Multilingual-V3-Lader lädt selektiv `t3_mtl23ls_v3.safetensors`, `s3gen.pt`, `ve.pt`, `conds.pt` und drei Tokenizerdateien, zusammen ungefähr 3,21 GB. Voller ROCm-Systemstack, AMD-Wheels und diese Modelldateien würden den kumulierten Verbrauch auf ungefähr 18,72 GB bringen, noch ohne übrige Chatterbox-Abhängigkeiten.
- U3B war deshalb zunächst blockiert. Vor der Treiber-/ROCm-Installation waren eine kontrollierte Kernelstrategie und eine Budgetentscheidung erforderlich.
- Der Benutzer hat Kernel `6.17.0-14-generic` am 2026-09-07 erfolgreich einmalig über GRUB gestartet. Liveprüfung bestätigt diesen aktiven Kernel; GRUB steht jedoch weiterhin auf dem automatisch neuesten Eintrag (`GRUB_DEFAULT=0`).
- U3K wurde mit `scripts/u3k_pin_kernel_6_17.sh` vorbereitet. Der Helfer validiert den vorhandenen Menüpfad, sichert `/etc/default/grub`, setzt Kernel 6.17 als Standard, macht das Menü fünf Sekunden sichtbar und führt `update-grub` aus; bei einem Fehler stellt er die Sicherung wieder her.
- U3K wurde anschließend ausgeführt und nach dem Neustart verifiziert: `6.17.0-14-generic` ist aktiv und dauerhaftes GRUB-Ziel, das Menü ist fünf Sekunden sichtbar, die Sicherung `/etc/default/grub.u3k-backup-20260907T202040Z` existiert und Secure Boot bleibt aktiviert. U3K ist PASS; Download 0 GB.
- Der Benutzer hat U3B anschließend ausdrücklich für maximal 6.856.000.000 Byte Paketdownload und die Systeminstallation `graphics,rocm` einschließlich `amdgpu-dkms` freigegeben.
- Die aktuelle Wiederholung der Simulation bestätigt den freigegebenen Stand exakt: 444 neue Pakete, 0 Upgrades, 0 Entfernungen und 6.855.525.228 Byte Download.
- `scripts/u3b_install_rocm.sh` und `docs/U3B_RUNBOOK.md` sind vorbereitet. Der Helfer erzwingt die Kernel-, GRUB-, GPU-, Geräte-, Secure-Boot-, Versions-, Paketanzahl-, Download- und Speichergrenzen vor Beginn der Installation. Ausführung im normalen Ubuntu-Terminal steht noch aus.
- U3B wurde ausgeführt. `rocm`, `amdgpu-lib` und `rocminfo` sind installiert; `amdgpu-dkms` ist für Kernel 6.17 als `installed` registriert, blieb aber als Debian-Paket halb konfiguriert, weil der Postinstallationslauf zusätzlich Kernel 7.0 bauen wollte und an dessen inkompatiblen Schnittstellen scheiterte.
- Der Benutzer hat die Reparatur durch Entfernung exakt der fünf inaktiven Kernel-7.0-/HWE-Pakete ausdrücklich freigegeben. `scripts/u3b_repair_remove_kernel_7.sh` simuliert und erzwingt genau diese Liste, führt kein `autoremove` aus und schließt anschließend `dpkg`, DKMS und GRUB kontrolliert ab. Reparaturausführung steht noch aus; bis dahin nicht neu starten.
- Die U3B-Reparatur, der Neustart und die MOK-Einschreibung wurden erfolgreich abgeschlossen. Liveprüfung bestätigt Kernel 6.17, Secure Boot, den eingeschriebenen lokalen MOK-Schlüssel, vollständig konfigurierte ROCm-Pakete sowie das signierte und geladene AMD-DKMS-Modul 6.16.13.
- Der korrigierte Helfer `scripts/u3b_postflight.sh` wurde im normalen Benutzerterminal erfolgreich ausgeführt. Er bestätigt Lese-/Schreibzugriff auf `/dev/kfd` und `/dev/dri/renderD128`, `gfx1101`, die RX 7700 XT sowie genau ein OpenCL-GPU-Gerät. U3B und ROCm sind damit **PASS**; Nachweise liegen unter `work/u3b-postflight/`.
- U3C beginnt ausschließlich mit Planung: Python 3.12.3 und `pip` 24.0 sind vorhanden, `python3.12-venv` fehlt. PyTorch-Wheels oder andere Pakete werden erst nach Konflikt-, Größen- und Freigabeprüfung heruntergeladen.
- U3C1 ist vorbereitet, aber nicht freigegeben: `docs/U3C_PYTORCH_PLAN.md` und `scripts/u3c1_prepare_venv.sh` begrenzen den ersten Schritt auf genau drei Venv-Pakete und höchstens 2.428.604 Byte. U3C2 und Chatterbox bleiben ausgeschlossen.
- Projektorganisationshinweis: `/home/tille/Projects/TilleVoiceStudio` ist derzeit kein Git-Repository. Das blockiert U2 nicht, sollte aber vor umfangreichen Projektänderungen geklärt werden.
