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
| Codex CLI Standalone für Ubuntu | am Installationstag zu verifizieren | offizieller OpenAI-Installer | maximal 0,250 GB reserviert | 0 GB | 6,658 GB tatsächlich | RESERVIERT, nicht heruntergeladen | 2026-09-05 |
| W8 – sicherer Betriebssystemwechsel | lokal | geordneter Windows-Shutdown | 0 GB | 0 GB | 6,658 GB | vom Benutzer freigegeben | 2026-09-05 |

## Aktueller Stand

- Tatsächliches Downloadvolumen: **6,658 GB** (6.657.609.064 Byte)
- Verbleibendes Budget: **13,342 GB**
- Davon für die spätere Codex-CLI-Installation reserviert: **0,250 GB**
- Nach Reservierungen noch nicht verplant: **13,092 GB**
- Installierter Speicherplatz und Downloadvolumen werden getrennt erfasst.
- Vor jedem tatsächlichen Download ist die im Master-Workflow festgelegte Einzel-Freigabe erforderlich.

## Noch nicht freigegebene Planwerte

- AMD-PyTorch-Wheel-Satz für ROCm 7.2.1: rund 1,94 GB
- Codex CLI Standalone für Linux: konservativ maximal 0,250 GB reserviert; aktuelle offizielle Standardinstallation benötigt kein Node.js/npm.
- Diese Werte sind nicht als Verbrauch gebucht; weder Wheels noch Codex wurden heruntergeladen.

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
