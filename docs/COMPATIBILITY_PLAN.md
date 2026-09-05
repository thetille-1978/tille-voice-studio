# Kompatibilitätsplan – Tille Voice Studio

- Stand der Recherche: 2026-09-05
- Phase: W1
- Rechercheumfang: ausschließlich offizielle Ubuntu-, AMD/ROCm-, PyTorch- und ResembleAI-Quellen
- Tatsächliche Downloads in W1: 0 GB; aktueller Projektstand nach W3: 6,658 GB
- Systemänderungen: keine

## Entscheidung in Kurzform

Die derzeit sinnvollste und offiziell unterstützte Linux-Basis für die vorhandene AMD Radeon RX 7700 XT ist:

- Ubuntu 24.04.4 LTS Desktop AMD64
- Ubuntu-HWE-Kernel 6.17
- AMD Radeon Software/ROCm 7.2.1 als kohärenter, Radeon-spezifisch dokumentierter Produktionspfad
- Python 3.12
- PyTorch 2.9.1 für ROCm 7.2.1
- Torchvision 0.24.0
- Torchaudio 2.9.0
- Triton 3.5.1
- Chatterbox TTS 0.1.7 mit Chatterbox Multilingual V3 – Integration **NOCH OFFEN**, da die offiziellen Chatterbox-Abhängigkeiten unter Python 3.12 noch Torch und Torchaudio 2.6.0 erzwingen

Ubuntu 24.04.4 ist nicht nur das aktuell veröffentlichte 24.04-Installationsmedium, sondern zugleich genau die Ubuntu-Point-Release, die AMD für die RX 7700 XT aktuell aufführt. Ubuntu 24.04.5 ist für den 10. September 2026 geplant und war am Recherchetag noch nicht im offiziellen Release-Verzeichnis veröffentlicht. Ein Wechsel auf 24.04.5 wird deshalb nicht vorweggenommen.

## Kompatibilitätsmatrix

| Komponente | Zielversion / Ergebnis | Status | Begründung |
|---|---|---|---|
| Ubuntu | 24.04.4 LTS Desktop AMD64 | **VERIFIZIERT** | Aktuell veröffentlichtes 24.04-LTS-Desktopmedium; von AMD für die RX 7700 XT unterstützt |
| Kernel | Ubuntu 6.17 HWE | **VERIFIZIERT** | AMD führt Ubuntu 24.04.4 mit Kernel 6.17 HWE als unterstützte Radeon-Konfiguration; 6.8 GA ist in der allgemeinen ROCm-Matrix ebenfalls unterstützt |
| RX 7700 XT | RDNA3, 12 GB | **VERIFIZIERT** | AMD führt die RX 7700 XT in der Linux-Unterstützung auf |
| gfx1101 | LLVM-/GPU-Ziel der RX 7700 XT | **VERIFIZIERT** | AMD ordnet die RX 7700 XT offiziell `gfx1101` zu |
| ROCm | 7.2.1, Radeon-Produktionspfad | **VERIFIZIERT** | Aktuelle Radeon-spezifische Dokumentation und PyTorch-Matrix sind auf 7.2.1 abgestimmt |
| Python | 3.12 | **VERIFIZIERT** | Ubuntu 24.04 verwendet Python 3.12; AMDs dokumentierte Radeon-Wheels für Ubuntu 24.04 sind `cp312` |
| PyTorch | 2.9.1 + ROCm 7.2.1 | **VERIFIZIERT für AMD** / Chatterbox-Kopplung **NOCH OFFEN** | AMD bezeichnet diese Kombination als offiziellen Produktionssupport; Chatterbox 0.1.7 pinnt unter Python 3.12 noch Torch 2.6.0 |
| Torchaudio | 2.9.0 + ROCm 7.2.1 | **VERIFIZIERT für AMD** / Chatterbox-Kopplung **NOCH OFFEN** | Bestandteil des offiziellen AMD-Wheel-Satzes; Chatterbox 0.1.7 pinnt unter Python 3.12 noch Torchaudio 2.6.0 |
| Torchvision | 0.24.0 + ROCm 7.2.1 | **VERIFIZIERT** | Bestandteil des offiziellen AMD-Wheel-Satzes |
| Triton | 3.5.1 + ROCm 7.2.1 | **VERIFIZIERT** | AMD nennt das genaue Wheel im aktuellen Radeon-PyTorch-Installationspfad |
| Chatterbox | Paket 0.1.7; Multilingual V3, 500M, Deutsch unterstützt | Modell/API **VERIFIZIERT**; Installation mit AMD-Produktions-Torch **NOCH OFFEN** | Offizielle ResembleAI-Quellen bestätigen V3 und Deutsch; der aktuelle Dependency-Pin kollidiert mit AMDs Radeon-Produktionsversion |

## Ubuntu-ISO

| Merkmal | Ergebnis |
|---|---|
| Produkt | Ubuntu 24.04.4 LTS Desktop |
| Architektur | AMD64 / x86-64 |
| Dateiname | `ubuntu-24.04.4-desktop-amd64.iso` |
| Offizielle Verzeichnisangabe | 6.2G |
| Exakte lokale Dateigröße | 6.655.619.072 Byte (6,656 GB / 6,199 GiB) |
| SHA256 | `3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e` |
| Downloadquelle | `https://releases.ubuntu.com/24.04/ubuntu-24.04.4-desktop-amd64.iso` |
| Prüfsummenquelle | `https://releases.ubuntu.com/24.04/SHA256SUMS` |
| Bereits heruntergeladen | Ja, in Phase W2 |
| Lokaler Pfad | `A:\TilleVoiceStudioDownloads\downloads\ubuntu-24.04.4-desktop-amd64.iso` |
| Prüfsummenvergleich | **PASS** |

Die offizielle Verzeichnisanzeige rundet die ISO-Größe auf 6.2G. Phase W2 ermittelte nach dem freigegebenen Download die exakte Größe von 6.655.619.072 Byte. Die lokal berechnete SHA256-Prüfsumme stimmt exakt mit der offiziellen Ubuntu-Prüfsumme überein.

### Warum nicht Ubuntu 24.04.5?

Der offizielle Noble-Zeitplan nennt den 10. September 2026 als geplanten Termin für 24.04.5. Am 5. September 2026 enthält das offizielle Release-Verzeichnis noch 24.04.4 als neuestes Desktopmedium. Zusätzlich validiert AMD die RX 7700 XT derzeit ausdrücklich auf Ubuntu 24.04.4. Deshalb wird 24.04.4 geplant. Falls W2 erst nach Veröffentlichung von 24.04.5 beginnt, müssen Release-Verzeichnis und AMD-Matrix erneut geprüft werden; es erfolgt kein automatischer Wechsel.

## ROCm- und Radeon-Auswahl

AMDs allgemeine Produktionsdokumentation ist bereits bei ROCm 7.2.3 und bestätigt für die RX 7700 XT Ubuntu 24.04.4 sowie `gfx1101`. Die aktuelle, speziell für Radeon-Workstations veröffentlichte Framework-Matrix und die dazugehörigen Linux-PyTorch-Wheels verwenden jedoch ROCm 7.2.1.

Für dieses Projekt wird daher konservativ ROCm 7.2.1 als zusammenhängender Radeon-/PyTorch-Pfad vorgesehen. Dadurch stammen GPU-Support, Installationsanleitung und die vier Python-Wheels aus derselben offiziell dokumentierten Matrix. ROCm 7.2.3 wird nicht ungeprüft mit 7.2.1-Wheels gemischt.

ROCm 7.13.0 ist ein separater Technology-Preview-Zweig. Er wird nicht als Produktionsbasis gewählt. Ein Preview-Stack wäre für dieses downloadbegrenzte, langfristig wartbare Projekt unnötig riskant.

## Offizieller AMD-PyTorch-Satz

Für Ubuntu 24.04 und Python 3.12 dokumentiert AMD folgende Kombination:

| Paket | Version | Offizielle Dateigröße laut Repositoryindex |
|---|---:|---:|
| Torch | 2.9.1 + ROCm 7.2.1 | 1.650.644.034 Byte |
| Torchvision | 0.24.0 + ROCm 7.2.1 | 2.946.390 Byte |
| Torchaudio | 2.9.0 + ROCm 7.2.1 | 488.612 Byte |
| Triton | 3.5.1 + ROCm 7.2.1 | 287.563.448 Byte |
| **Summe der vier Wheels** | | **1.941.642.484 Byte, rund 1,94 GB** |

Diese Größen sind nur Metadaten aus dem offiziellen Repositoryindex. Es wurde nichts davon heruntergeladen. Weitere Abhängigkeiten und ROCm-Systempakete sind in dieser Summe nicht enthalten.

## Chatterbox Multilingual V3

Die offiziellen ResembleAI-Quellen bestätigen:

- Chatterbox Multilingual V3 ist das aktuelle allgemeine mehrsprachige Modell.
- Das Modell besitzt ungefähr 500 Millionen Parameter.
- Deutsch (`de`) gehört zu den unterstützten Sprachen.
- Die aktuelle API verwendet `ChatterboxMultilingualTTS` und wählt V3 mit `t3_model="v3"`.
- Der aktuelle Repositorystand meldet die Paketversion 0.1.7 und Python `>=3.10`.

### Offener Versionskonflikt

`chatterbox-tts` 0.1.7 verlangt laut offiziellem `pyproject.toml` bei Python-Versionen unter 3.14:

- `torch==2.6.0`
- `torchaudio==2.6.0`

AMDs offiziell validierter Produktionssatz für die RX-7700-XT-/ROCm-7.2.1-Konfiguration verwendet dagegen:

- `torch==2.9.1`
- `torchaudio==2.9.0`

Ein normales `pip install chatterbox-tts` könnte deshalb versuchen, die korrekten AMD-GPU-Wheels zu ersetzen. Das wäre nach den Projektregeln ein sofortiger Stoppgrund.

### Nicht gewählte Scheinlösung

PyTorch und Torchaudio 2.6.0 sind zwar als ältere ROCm-6.2.4-Wheels bei PyTorch vorhanden. AMDs damalige offizielle Linux-GPU-Liste für ROCm 6.2.4 enthält die RX 7700 XT jedoch nicht; außerdem ist ROCm 6.2.4 nicht für Ubuntu 24.04.4 mit Kernel 6.17 validiert. Dieser ältere Stack wird daher nicht als offizielle Lösung geplant.

### Geplanter kleinster Klärungsschritt

Noch vor einer Chatterbox-Installation sind später folgende Prüfungen vorgesehen:

1. Den offiziellen Chatterbox-Repositorystand und `pyproject.toml` am Installationstag erneut prüfen.
2. Die Abhängigkeitsauflösung zunächst per Dry Run/Report untersuchen, ohne die funktionierende AMD-Torch-Installation verändern zu lassen.
3. Prüfen, ob Chatterbox mit Torch 2.9.1 und Torchaudio 2.9.0 ohne Codeänderung importiert und einen CPU-/Mock-Test besteht.
4. Falls die Laufzeit kompatibel ist, die veralteten Pins nur im lokalen Projekt kontrolliert anpassen oder Chatterbox ohne Dependency-Neuauflösung installieren.
5. Erst anschließend einen kurzen GPU-Test und danach den V3-Modellabruf freigeben.

Bis diese Tests erfolgreich sind, bleibt die exakte Chatterbox-/Torch-Kopplung **NOCH OFFEN**. Es wird jetzt weder ein Patch noch eine Installation vorgenommen.

## Secure Boot

Secure Boot ist auf dem Windows-System aktiviert. Ubuntu 24.04 unterstützt Secure Boot über Microsoft-signiertes `shim` sowie Canonical-signierte GRUB- und Kernelkomponenten.

Für externe DKMS-Kernelmodule gilt:

- Ubuntu signiert lokal gebaute Drittanbieter-DKMS-Module über einen Machine Owner Key (MOK).
- Der MOK muss bei einem folgenden Neustart über MokManager bestätigt werden.
- AMD weist darauf hin, dass `amdgpu-dkms` bei aktiviertem Secure Boot signiert werden muss, andernfalls kann das Modul nicht geladen werden.

Empfehlung: Secure Boot nicht vorschnell deaktivieren. Falls die spätere AMD-Treiberinstallation tatsächlich `amdgpu-dkms` benötigt, soll der offizielle MOK-Signierungsweg geplant und einzeln freigegeben werden. Die konkrete Treiberstrategie wird erst auf dem installierten Ubuntu anhand von Kernel und vorhandenem `amdgpu` festgelegt.

## Downloadbudget-Auswirkung

- Bisheriger tatsächlicher Projektverbrauch: 6,658 GB
- W1-Recherche: 0 GB tatsächlicher Download
- Ubuntu-ISO in W2: 6,656 GB tatsächlich heruntergeladen
- Rufus Portable in W3: 0,001990 GB tatsächlich heruntergeladen
- Verbleibendes Gesamtbudget: 13,342 GB
- Offizieller AMD-PyTorch-Wheel-Satz: rund 1,94 GB, noch nicht freigegeben und nicht heruntergeladen
- ROCm-Pakete, weitere Python-Abhängigkeiten, Chatterbox und Modelldateien sind noch nicht vollständig beziffert

Das 20-GB-Budget erscheint grundsätzlich erreichbar, ist aber noch nicht abschließend verifiziert. Vor den ROCm-, Python- und Modellphasen müssen Paketmetadaten beziehungsweise Dry-Run-Berichte die noch offenen Größen liefern. Doppelte Torch-Versionen sind unbedingt zu vermeiden.

## Quellen

### Ubuntu

- [Offizielles Ubuntu-24.04-Release-Verzeichnis](https://releases.ubuntu.com/24.04/)
- [Offizielle SHA256SUMS](https://releases.ubuntu.com/24.04/SHA256SUMS)
- [Offizieller Noble-Numbat-Zeitplan](https://discourse.ubuntu.com/t/noble-numbat-release-schedule/35649)
- [Ubuntu Secure Boot](https://documentation.ubuntu.com/security/security-features/platform-protections/secure-boot/)

### AMD/ROCm

- [Radeon Linux-Kompatibilitätsmatrix](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/compatibility/compatibilityrad/native_linux/native_linux_compatibility.html)
- [ROCm-7.2.3-Systemanforderungen für Linux](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.3/reference/system-requirements.html)
- [PyTorch für Radeon unter Linux](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-pytorch.html)
- [Offizieller AMD-Wheel-Index für ROCm 7.2.1](https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.1/)
- [ROCm-Installationsvoraussetzungen einschließlich Secure Boot](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.1/install/prerequisites.html)

### ResembleAI Chatterbox

- [Offizielles Chatterbox-Repository](https://github.com/resemble-ai/chatterbox)
- [Aktuelles offizielles pyproject.toml](https://github.com/resemble-ai/chatterbox/blob/master/pyproject.toml)
- [Offizielle Hugging-Face-Modellkarte](https://huggingface.co/ResembleAI/chatterbox/blob/main/README.md)
- [Historische ROCm-6.2.4-Systemanforderungen](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.2.4/reference/system-requirements.html)

## Checkpoint W1

Status: **PASS**

Erfolgreich:

- Aktuelles verfügbares Ubuntu-24.04-LTS-Desktopmedium bestimmt
- Offiziellen Dateinamen, gerundete Größe und SHA256-Prüfsumme bestimmt
- RX 7700 XT und `gfx1101` in AMDs aktueller Linux-Unterstützung bestätigt
- Unterstützte Ubuntu- und Kernelkombination bestimmt
- Kohärenten ROCm-/Python-/PyTorch-/Torchaudio-/Torchvision-/Triton-Satz bestimmt
- Secure-Boot-/DKMS-Besonderheiten dokumentiert
- Chatterbox Multilingual V3 und Deutsch-Unterstützung bestätigt
- Chatterbox-/Torch-Pin-Konflikt vor jedem Download erkannt und dokumentiert
- Keine Downloads und keine Systemänderungen durchgeführt

Problem:

- Chatterbox 0.1.7 pinnt unter Python 3.12 Torch/Torchaudio 2.6.0; AMD validiert für die RX 7700 XT aktuell Torch 2.9.1/Torchaudio 2.9.0. Die Laufzeitkompatibilität mit kontrolliert angepassten Pins muss später getestet werden.

Nächster vorgesehener Schritt:

- Zum Zeitpunkt dieses W1-Checkpoints war Phase W2 der nächste Schritt. W2 wurde anschließend nach ausdrücklicher Downloadfreigabe erfolgreich abgeschlossen.
- Phase W3 wurde anschließend erfolgreich abgeschlossen; Rufus 4.15.2396 Portable x64 besitzt eine gültige Authenticode-Signatur.
- W4 wurde anschließend nach Backup-Bestätigung ohne zusätzliche Systemänderung erfolgreich abgeschlossen.
- W5 wurde nach separater Systemänderungs-Freigabe erfolgreich abgeschlossen: `A:` wurde exakt um 100 GiB verkleinert; 100,001 GiB bleiben unformatiert und nicht zugeordnet.
- Nächster vorgesehener Schritt ist Phase W6: USB-Stick eindeutig identifizieren und vor jedem Löschen eine separate USB-LÖSCHBESTÄTIGUNG einholen.
