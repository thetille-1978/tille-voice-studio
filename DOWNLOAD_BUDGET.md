# Downloadbudget – Tille Voice Studio

- Gesamtbudget: 20 GB
- Warnstufe: ab 15 GB
- Keine optionalen Downloads ohne besondere Begründung: ab 18 GB
- Harter Stopp: ab 20 GB

| Komponente | Version | Quelle | Geschätzt | Tatsächlich | Kumuliert | Status | Datum |
|---|---|---|---:|---:|---:|---|---|
| Windows-Preflight W0 | lokal | lokale Systemdiagnose | 0 GB | 0 GB | 0 GB | PASS, kein Download | 2026-09-05 |
| Kompatibilitätsrecherche W1 | lokal/Web-Metadaten | offizielle Dokumentation | 0 GB | 0 GB | 0 GB | PASS, kein Datei-/Paketdownload | 2026-09-05 |
| Ubuntu Desktop ISO | 24.04.4 LTS AMD64 | `releases.ubuntu.com` | 6,66 GB | 6,656 GB (6.655.619.072 Byte) | 6,656 GB | PASS, SHA256 verifiziert | 2026-09-05 |
| Rufus Portable x64 | 4.15.2396 | offizielles `pbatard/rufus`-GitHub-Release | 0,002 GB | 0,001990 GB (1.989.992 Byte) | 6,658 GB | PASS, Authenticode gültig; in W6 verwendet | 2026-09-05 |
| Ubuntu-Installationsmedium W6 | Ubuntu 24.04.4 LTS | lokale, verifizierte ISO | 0 GB Netzwerkdownload | 0 GB Netzwerkdownload | 6,658 GB | PASS, Intenso-USB-Stick erfolgreich beschrieben | 2026-09-05 |
| W7-Readiness und Übergabe | lokal/Web-Metadaten | lokale Diagnose und offizielle OpenAI-Dokumentation | 0 GB | 0 GB | 6,658 GB | PASS, kein Datei-/Paketdownload | 2026-09-05 |
| Codex CLI Standalone für Ubuntu | am Installationstag zu verifizieren | offizieller OpenAI-Installer | maximal 0,250 GB reserviert | 0 GB | 6,658 GB tatsächlich | RESERVIERT, nicht heruntergeladen; gebündelte Codex CLI bereits vorhanden | 2026-09-06 |
| W8 – sicherer Betriebssystemwechsel | lokal | geordneter Windows-Shutdown | 0 GB | 0 GB | 6,658 GB | vom Benutzer freigegeben | 2026-09-05 |
| U0 – Ubuntu-Installation | 24.04.4 LTS Desktop AMD64 | lokaler verifizierter USB-Stick | 0 GB | 0 GB | 6,658 GB | PASS, nativer Start bestätigt | 2026-09-06 |
| U1 – Codex unter Ubuntu | gebündelte Codex CLI 0.153.4 | bereits lokal vorhanden | 0 GB | 0 GB | 6,658 GB | PASS, kein Projekt-Download | 2026-09-06 |
| U2 – nativer Hardware-Preflight | lokale Systemdiagnose | lokal | 0 GB | 0 GB | 6,658 GB | PASS, kein Download | 2026-09-06 |
| U3 – ROCm-Planungsprüfung | lokale Diagnose/Web-Metadaten | offizielle AMD-Dokumentation und HTTP-Header | 0 GB Nutzdateien | 0 GB Nutzdateien | 6,658 GB | PLAN READY, keine Installation | 2026-09-06 |
| U3A – Repository-Bootstrap und Simulation | ROCm 7.2.1 / AMDGPU 30.30.1 | offizielle AMD-/Ubuntu-Paketquellen | ca. 0,054 GB | ca. 0,0534 GB einschließlich APT-Metadaten | ca. 6,711 GB | PASS; nur `amdgpu-install` installiert, kein ROCm/DKMS | 2026-09-06 |
| U3B – ROCm-Systemstack | ROCm 7.2.1 / AMDGPU 30.30.1 | offizielle AMD-/Ubuntu-Paketquellen | 6,856 GB | ca. 6,856 GB / 6.855.525.228 Byte Paketnutzlast | ca. 13,567 GB | PASS; Installation, Reparatur, MOK und Postflight abgeschlossen | 2026-09-07 |

## Aktueller Stand

- Tatsächliches Downloadvolumen: **ca. 13,567 GB**
- Verbleibendes Budget: **ca. 6,433 GB**
- Davon für die spätere Codex-CLI-Installation reserviert: **0,250 GB**
- Nach Reservierungen noch nicht verplant: **ca. 6,183 GB**
- Installierter Speicherplatz und Downloadvolumen werden getrennt erfasst.
- Vor jedem tatsächlichen Download ist die im Master-Workflow festgelegte Einzel-Freigabe erforderlich.
- U3B wurde separat für höchstens 6.856.000.000 Byte Paketnutzlast freigegeben. Die installierte Paketnutzlast von 6.855.525.228 Byte ist als Verbrauch gebucht; die Reparatur selbst benötigt keinen Download.

## Plan- und Freigabewerte

- U3C1-Venv-Voraussetzung: exakt 2.428.604 Byte / 0,002429 GB für `python3-pip-whl`, `python3-setuptools-whl` und `python3.12-venv`; geplant, noch nicht freigegeben oder heruntergeladen
- AMD-PyTorch-Wheel-Satz für ROCm 7.2.1: exakt 1.941.642.484 Byte / 1,942 GB laut offiziellen HTTP-Dateimetadaten
- ROCm-Vollstack laut protokollierter U3A- und U3B-Simulation: 6.855.525.228 Byte / 6,856 GB; 444 neue Pakete, keine Upgrades oder Entfernungen; **heruntergeladen, installiert und mit Postflight verifiziert**
- Vollstack plus AMD-Framework-Wheels: 8.797.167.712 Byte / 8,797 GB; kumuliert danach ungefähr 15,509 GB und damit oberhalb der Warnstufe, noch ohne Chatterbox und Modell
- Vom offiziellen Chatterbox-Multilingual-V3-Lader selektiv angeforderte Modelldateien: ungefähr 3,21 GB (`t3_mtl23ls_v3.safetensors`, `s3gen.pt`, `ve.pt`, `conds.pt` und Tokenizerdateien); kumuliert mit Vollstack und Wheels ungefähr 18,72 GB
- Die übrigen Chatterbox-Python-Abhängigkeiten sind noch nicht beziffert. Der volle Pfad ist daher innerhalb des 20-GB-Limits noch nicht nachgewiesen und liegt bereits über der 18-GB-Sparstufe.
- Nur-Lese-Vergleich: `rocm-ml-libraries` ohne Grafik/DKMS ca. 4,924 GB; nur `rocm-hip-runtime` ca. 0,779 GB. Beide Varianten sind nicht als Ersatz für AMDs Radeon-Standardbefehl freigegeben.
- Codex CLI Standalone für Linux: konservativ maximal 0,250 GB reserviert; aktuelle offizielle Standardinstallation benötigt kein Node.js/npm.
- Die ROCm-Nutzlast ist als Verbrauch gebucht. Framework-Wheels und eine eigenständige Codex-CLI wurden nicht heruntergeladen.

## ISO-Nachweis

- Datei: `A:\TilleVoiceStudioDownloads\downloads\ubuntu-24.04.4-desktop-amd64.iso`
- SHA256: `3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e`
- Vergleich mit offizieller Ubuntu-Prüfsumme: **PASS**

## Rufus-Nachweis

- Datei: `A:\TilleVoiceStudioDownloads\downloads\rufus-4.15p.exe`
- Version: 4.15.2396, Portable x64
- Größe: 1.989.992 Byte
- SHA256: `84c8a437f8af89257524478489e5c85f1edf25f761d299e2bcde46ac0afbe106`
- Authenticode: **Valid**, signiert von Akeo Consulting
- Rufus wurde in W6 nach gerätespezifischer Löschbestätigung verwendet. Ausschließlich der freigegebene Intenso Rainbow Line USB-Stick wurde beschrieben; dies verursachte keinen zusätzlichen Netzwerkdownload.
