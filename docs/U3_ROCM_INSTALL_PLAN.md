# U3 – ROCm-Installationsplan

- Planungsstand: 2026-09-07
- Status: **U3A PASS / U3K PASS / U3B PASS – U3C-PLANUNG OFFEN**
- Planung: offizielle AMD-Quellen und lokale Nur-Lese-Prüfungen
- Ausgeführte Downloads in U3: ca. 6,909 GB einschließlich U3A-Metadaten und U3B-Paketnutzlast
- Installiert in U3: ROCm 7.2.1 und der Radeon-Stack `graphics,rocm` einschließlich signiertem AMD-DKMS 6.16.13; noch kein Framework

## Ziel

ROCm 7.2.1 auf Ubuntu 24.04.4 für die AMD Radeon RX 7700 XT kontrolliert installieren und zunächst unabhängig von PyTorch und Chatterbox mit `rocminfo` verifizieren.

## Erneut bestätigte Zielkombination

Die am 2026-09-06 erneut geprüfte AMD-Radeon-Matrix bestätigt:

- Ubuntu 24.04.4 Desktop mit HWE-Kernel 6.17: unterstützt
- AMD Radeon RX 7700 XT: unterstützt
- ROCm 7.2.1: vorgesehener Radeon-Pfad
- PyTorch 2.9.1 mit ROCm 7.2.1: offizieller Produktionssupport
- Triton 3.5.1: offizieller Produktionssupport

Offizielle Quellen:

- https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/compatibility/compatibilityrad/native_linux/native_linux_compatibility.html
- https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-radeon.html
- https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-pytorch.html
- https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.1/install/prerequisites.html

## Lokaler Ausgangszustand vor U3B

- Ubuntu 24.04.4 läuft aktuell mit Kernel `7.0.0-31-generic`. U2 wurde zuvor unter `6.17.0-14-generic` bestanden; dieser Kernel und seine Header sind weiterhin installiert.
- Die Header `linux-headers-6.17.0-14-generic` sind installiert.
- Der Ubuntu-Kerneltreiber `amdgpu` initialisiert Grafik, DRM und KFD erfolgreich.
- `/dev/kfd` und `/dev/dri/renderD128` sind für den Benutzer effektiv les- und schreibbar.
- `python3-pip`, `python3-wheel`, Setuptools, DKMS und ROCm-Pakete sind nicht installiert.
- Das offizielle Paket `amdgpu-install` in Version `30.30.1.0.30300100-2303411.24.04` ist installiert und hat die signierten AMD-Quellen für ROCm 7.2.1 und AMDGPU 30.30.1 registriert.
- Die HWE-Metapakete zeigen auf `7.0.0-31-generic`, und `GRUB_DEFAULT=0` startet standardmäßig den neuesten Kernel. Der Neustart am 2026-09-07 hat deshalb bereits Kernel 7.0 aktiviert.
- Secure Boot ist aktiviert.

## Treiberentscheidung

Die Radeon-spezifische AMD-Anleitung empfiehlt `amdgpu-install` mit dem Usecase `graphics,rocm`. Dieser Pfad installiert einen kohärenten Radeon-Grafik-/ROCm-Stack, kann aber `amdgpu-dkms` einführen. AMD verlangt bei aktiviertem Secure Boot die Signierung dieses DKMS-Moduls und anschließend einen Neustart beziehungsweise eine MOK-Bestätigung.

Der vorhandene Ubuntu-`amdgpu`-Treiber funktioniert bereits. Ein undokumentierter Wechsel zu `--no-dkms` wird für die dedizierte Radeon nicht vorweggenommen; AMD schreibt diesen Schalter in der aktuellen Spezialdokumentation ausdrücklich für Ryzen-APUs vor, nicht für den Radeon-Pfad.

Empfehlung: Den Radeon-spezifisch dokumentierten `graphics,rocm`-Pfad nur nach einem Wiederherstellungs- und Secure-Boot-Checkpoint ausführen. Nicht parallel PyTorch oder Chatterbox installieren.

## Bekannte Downloadgrößen

Per HTTP-Header der offiziellen AMD-Adressen ermittelt; keine Nutzdatei wurde heruntergeladen:

| Datei | Byte | Dezimal |
|---|---:|---:|
| `amdgpu-install_7.2.1.70201-1_all.deb` | 16.908 | 0,000017 GB |
| PyTorch-2.9.1-ROCm-Wheel | 1.650.644.034 | 1,651 GB |
| Torchvision-0.24.0-ROCm-Wheel | 2.946.390 | 0,002946 GB |
| Triton-3.5.1-ROCm-Wheel | 287.563.448 | 0,288 GB |
| Torchaudio-2.9.0-ROCm-Wheel | 488.612 | 0,000489 GB |
| **Vier Framework-Wheels zusammen** | **1.941.642.484** | **1,942 GB** |

Nicht enthalten sind Ubuntu-Paketmetadaten, Voraussetzungen, ROCm-Systempakete, deren Abhängigkeiten, Chatterbox und das Sprachmodell. Die 1,942 GB dürfen deshalb noch nicht als Gesamtgröße der nächsten Installation verwendet werden.

## Ergebnis U3A

U3A wurde am 2026-09-06 erfolgreich ausgeführt. Nachweisdateien:

- `work/u3a/u3a-session.log`
- `work/u3a/amdgpu-install-dryrun.txt`
- `work/u3a/apt-simulation.txt`
- `work/u3a/apt-download-uris.txt`

Verifizierter Bootstrap:

- Datei: `amdgpu-install_7.2.1.70201-1_all.deb`
- Größe: 16.908 Byte
- SHA256: `4c0338a241c15b12c14eb3aeb4012ea0d55dba681737ea8482248041a16c2afa`
- interner Paketstand: `30.30.1.0.30300100-2303411.24.04`

Das offizielle AMD-`--dryrun` plant:

```text
apt-get install -y amdgpu-lib rocm amdgpu-dkms linux-headers-6.17.0-14-generic linux-headers-7.0.0-31-generic
```

Die unabhängige APT-Simulation ergab für den vollständigen geplanten Satz einschließlich Python-Voraussetzungen:

- 444 Pakete neu, 0 entfernt
- 6.855.525.228 Byte / 6,856 GB Download
- davon ca. 6,539 GB aus AMD-Quellen und ca. 0,317 GB aus Ubuntu-Quellen

Zusätzliche Nur-Lese-Simulationen zeigen folgende Größenordnung:

| Variante | Neue Pakete | Download | Einordnung |
|---|---:|---:|---|
| vollständiger Referenzpfad, erneut simuliert | 449 | 6,865 GB | dokumentierter Radeon-Standardpfad plus Python-Voraussetzungen |
| `rocm-ml-libraries` ohne Grafik/DKMS | 147 | 4,924 GB | offizielles ML-Laufzeit-Metapaket, aber nicht der Radeon-Standardbefehl |
| nur `rocm-hip-runtime` | 100 | 0,779 GB | führt HIP-Anwendungen aus, enthält jedoch nicht die ML-Bibliotheken |

Die Abweichung 444/449 beim Referenzpfad beruht auf dem leicht unterschiedlichen lokalen Paketstand zwischen den Simulationen; maßgeblich für die protokollierte U3A-Ausführung sind 444 Pakete und 6.855.525.228 Byte.

## Kontrollierter Ablauf

### U3A – APT-Metadaten und exakte Simulation – PASS

Nach einer kleinen, getrennten Downloadfreigabe:

1. Ubuntu- und AMD-Paketquellen gemäß offizieller Anleitung registrieren.
2. Signaturschlüssel/Fingerprint prüfen.
3. Paketlisten aktualisieren.
4. `python3-setuptools`, `python3-wheel` und den geplanten AMD-Usecase ausschließlich simulieren.
5. Download- und Installationsgröße, Paketliste, DKMS- und Kernelwirkung erfassen.
6. `DOWNLOAD_BUDGET.md` aktualisieren.

### U3B – ROCm-Systemstack – PASS

Erst nach neuer, exakt bezifferter DOWNLOAD- und SYSTEMÄNDERUNGS-FREIGABE:

1. Voraussetzungen und AMD-Installerpaket installieren.
2. Vor dem eigentlichen Treiberschritt den verfügbaren Usecase erneut anzeigen und protokollieren.
3. Den freigegebenen Radeon-Usecase installieren.
4. Warnungen und Paketänderungen vollständig erfassen.
5. Falls MOK-Einrichtung verlangt wird, keine Zugangsdaten protokollieren und den vorgesehenen Neustart kontrolliert durchführen.
6. Nach dem Neustart Kernel, Secure Boot, `amdgpu`, Gruppenrechte, `/dev/kfd` und `/dev/dri/renderD128` erneut prüfen.
7. `rocminfo` und `clinfo` ausführen; `gfx1101` muss sichtbar sein.

### U3C – Framework erst nach ROCm-PASS

PyTorch, Torchvision, Torchaudio und Triton werden in einer separaten Python-Projektumgebung installiert. System-Python wird nicht mit `--break-system-packages` verändert. Vorher muss der bekannte Chatterbox-Pin-Konflikt weiterhin isoliert bleiben.

## Stoppbedingungen

Sofort stoppen bei:

- nicht auflösbaren APT-Abhängigkeiten oder ungeplantem Distributions-Upgrade,
- Austausch oder Entfernung des laufenden Kernels ohne vorherige Einzelprüfung,
- Secure-Boot-/MOK-Fehlern,
- nicht geladenem `amdgpu` nach Neustart,
- fehlendem Zugriff auf `/dev/kfd` oder `renderD128`,
- fehlender RX 7700 XT beziehungsweise fehlendem `gfx1101` in `rocminfo`,
- Überschreitung der vorher freigegebenen Downloadgröße,
- Versuch, Torch/Torchaudio ungeplant auf Chatterbox-Version 2.6.0 herunterzustufen.

## Aktueller Haltepunkt

U3A ist **PASS**. Die beiden danach erkannten Risiken wurden wie folgt behandelt:

1. Kernel 6.17 wurde über U3K wieder gestartet, dauerhaft als GRUB-Ziel gesetzt und nach dem Neustart verifiziert. Das GRUB-Menü ist fünf Sekunden sichtbar; die vorherige Konfiguration wurde gesichert.
2. Der dokumentierte Vollstack (6,856 GB) plus die vier Framework-Wheels (1,942 GB) würde den kumulierten Projektverbrauch auf ungefähr 15,509 GB erhöhen. Der aktuelle offizielle Chatterbox-V3-Lader fordert gezielt weitere ungefähr 3,21 GB Modelldateien an; damit läge das Projekt schon bei ungefähr 18,72 GB, bevor die übrigen Chatterbox-Python-Abhängigkeiten berücksichtigt sind.

Der Benutzer hat anschließend die U3B-DOWNLOAD- UND SYSTEMÄNDERUNGS-FREIGABE ausdrücklich erteilt. Die 6.855.525.228 Byte Paketnutzlast wurde installiert. Der zusätzliche DKMS-Build für Kernel 7.0 scheiterte; die separat freigegebene Reparatur entfernte daraufhin exakt die fünf vorgesehenen Kernel-7.0-/HWE-Pakete. Nach erfolgreicher MOK-Einschreibung laufen Kernel 6.17 und das signierte AMD-DKMS-Modul 6.16.13; alle ROCm-Pakete sind vollständig konfiguriert.

Der abschließende Benutzerterminal-Postflight vom 2026-09-07 ist **PASS**: `/dev/kfd` und `/dev/dri/renderD128` sind les- und schreibbar, `rocminfo` meldet `gfx1101` und die AMD Radeon RX 7700 XT, und `clinfo` erkennt genau ein OpenCL-GPU-Gerät mit rund 12,868 GB globalem Speicher. Nachweise liegen unter `work/u3b-postflight/`.

Der nächste Haltepunkt ist U3C. Python 3.12.3 und `pip` 24.0 sind vorhanden; `python3.12-venv` ist noch nicht installiert. Vor Downloads werden die isolierte Umgebung, der Chatterbox-Pin-Konflikt und die verbleibenden Abhängigkeitsgrößen geplant und danach separat freigegeben.
