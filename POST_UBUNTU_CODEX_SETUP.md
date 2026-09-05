# Codex unter Ubuntu einrichten

- Recherchestand: 2026-09-05
Ziel: Codex CLI nach der Ubuntu-Installation lokal verfügbar machen und per ChatGPT-Browseranmeldung authentifizieren.

## Aktueller offizieller Installationsweg

Die aktuelle offizielle OpenAI-Dokumentation empfiehlt für macOS und Linux einen eigenständigen Installer:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

Quelle: [Codex CLI – offizielle OpenAI-Dokumentation](https://learn.chatgpt.com/docs/codex/cli)

Dieser Stand ersetzt ältere Annahmen, dass Node.js und npm zwingend erforderlich seien. Für den bevorzugten eigenständigen Linux-Installer werden Node.js und npm laut aktuellem Schnellstart nicht vorausgesetzt. Sie werden deshalb weder vorab installiert noch im Budget als notwendiger Download angesetzt.

## Sehr wichtig: Noch nicht ungefragt ausführen

Der offizielle Befehl lädt Installer- und Programmdateien aus dem Internet. Er darf im Tille-Voice-Studio-Projekt erst nach der vorgeschriebenen **DOWNLOAD-FREIGABE** ausgeführt werden.

Vorher unter Ubuntu ausschließlich lesend prüfen:

```bash
command -v codex || true
codex --version 2>/dev/null || true
uname -m
```

Wenn Codex bereits vorhanden ist, wird nichts erneut heruntergeladen. Wenn es fehlt, werden am Installationstag die aktuelle offizielle Methode, erreichbare Quelle, Version soweit feststellbar und Downloadgröße nochmals geprüft.

## Budgetreservierung

- Bereits tatsächlich verbraucht: 6,658 GB
- Für Codex Standalone-Installer und CLI konservativ reserviert: maximal 0,250 GB
- Nach dieser Reservierung noch nicht verplant: 13,092 GB
- Tatsächlicher Codex-Download bisher: 0 GB
- Node.js/npm: 0 GB reserviert, weil für den aktuellen Standardweg nicht erforderlich

OpenAI veröffentlicht auf der Installationsseite keine feste Downloadgröße für jede künftige CLI-Version. Die 0,250-GB-Reserve ist daher eine konservative Projektplanung, keine behauptete Paketgröße. Wenn die ermittelte Größe darüber liegt, ist das Budget vor dem Download neu zu bewerten.

Vor dem Download muss dieses Formular ausgefüllt und bestätigt werden:

```text
--------------------------------------------------
DOWNLOAD-FREIGABE

Komponente: Codex CLI Standalone für Linux
Zweck: Projekt unter Ubuntu mit Codex fortsetzen
Version: am Installationstag aktuell und zu verifizieren
Quelle: https://chatgpt.com/codex/install.sh
Offizielle Quelle: JA

Geschätzter Download: maximal 0,250 GB reserviert
Bisheriger Projektverbrauch: 6,658 GB
Projektverbrauch danach: maximal 6,908 GB
Verbleibendes Budget von 20 GB: mindestens 13,092 GB

Bereits lokal vorhanden: zunächst prüfen
Download fortsetzbar: vor Ausführung prüfen

Soll der Download jetzt gestartet werden?
--------------------------------------------------
```

Erst nach einem ausdrücklichen **JA** darf der offizielle Installationsbefehl ausgeführt werden.

## Installation nach erteilter Downloadfreigabe

1. Nochmals die offizielle Seite öffnen und prüfen, dass der Linux-Befehl unverändert aktuell ist.
2. Den freigegebenen offiziellen Installer ausführen:

   ```bash
   curl -fsSL https://chatgpt.com/codex/install.sh | sh
   ```

3. Installation prüfen:

   ```bash
   command -v codex
   codex --version
   ```

4. Tatsächliches Downloadvolumen soweit zuverlässig erfassen und `DOWNLOAD_BUDGET.md` aktualisieren.

Wenn der Standalone-Installer fehlschlägt: **STOPP**. Nicht automatisch Node.js, npm oder eine alternative Codex-Version installieren. Zuerst Fehler erfassen und die dann aktuelle offizielle Dokumentation prüfen.

## Anmeldung mit ChatGPT

Die offizielle Dokumentation nennt zwei persönliche Anmeldewege: ChatGPT-Abonnement oder API-Key. Für dieses Projekt ist die browserbasierte ChatGPT-Anmeldung vorgesehen:

```bash
codex login
```

Der Befehl öffnet den Browser. Dort mit dem vorhandenen ChatGPT-Konto anmelden und anschließend zum Terminal zurückkehren. Alternativ kann beim ersten Start von `codex` „Sign in with ChatGPT“ gewählt werden.

Anmeldung kontrollieren:

```bash
codex login status
```

Quelle: [Authentication – offizielle OpenAI-Dokumentation](https://learn.chatgpt.com/docs/auth)

Ein API-Key ist für die vorgesehene ChatGPT-Anmeldung nicht erforderlich. API-Key-Nutzung würde stattdessen über das OpenAI-Platform-Konto verbrauchsabhängig abgerechnet und wird nicht automatisch eingerichtet.

## Zugangsdaten und Datenschutz

Die offizielle Dokumentation beschreibt, dass Codex Anmeldedaten lokal entweder in `~/.codex/auth.json` oder im betriebssystemspezifischen Credential Store zwischenspeichert.

- `~/.codex/auth.json` niemals in Git committen.
- Zugangsdaten nicht in `PROJECT_STATUS.md`, Logs oder Fehlerberichte kopieren.
- Private Referenzstimmen und Texte nicht an Codex oder andere Cloud-Dienste hochladen.
- Codex benötigt für Modellanfragen Internetzugriff. Die spätere Tille-Voice-Studio-App und ihre lokale Chatterbox-Inferenz sollen davon unabhängig offline funktionieren.

## Projekt fortsetzen

Den tatsächlichen Projektpfad unter Ubuntu zuerst eindeutig bestimmen. Beispiel, wenn das Projekt nach `~/Projects/TilleVoiceStudio` kopiert wurde:

```bash
cd ~/Projects/TilleVoiceStudio
git status
codex
```

Danach Codex anweisen:

```text
Lies CODEX_CONTINUE_AFTER_UBUNTU.md, PROJECT_STATUS.md,
DOWNLOAD_BUDGET.md und docs/COMPATIBILITY_PLAN.md vollständig.
Setze den vorhandenen Workflow nach dem letzten erfolgreichen
Checkpoint fort. Wiederhole keine Windows-, ISO- oder USB-Downloads.
```

## Update-Regel

Der offizielle Standalone-Installer wird laut OpenAI-Dokumentation auch für Updates erneut ausgeführt. Jedes spätere Update ist ein neuer Download und benötigt deshalb erneut eine Download-Freigabe. Keine automatische Aktualisierung im normalen Projektstart vorsehen.
