# U3C – isolierte PyTorch-/ROCm-Projektumgebung

- Stand: 2026-09-07
- Status: **PLAN READY – KEINE DOWNLOAD- ODER SYSTEMÄNDERUNGSFREIGABE**
- Ausgangspunkt: U3B und ROCm 7.2.1 **PASS**

## Ziel

PyTorch für die RX 7700 XT in einer isolierten Python-3.12-Projektumgebung installieren und zunächst unabhängig von Chatterbox mit der GPU verifizieren. Das System-Python wird nicht mit `--break-system-packages` verändert.

## Bestätigter lokaler Zustand

- Python 3.12.3 und `pip` 24.0 sind vorhanden.
- `python3.12-venv`, `python3-pip-whl` und `python3-setuptools-whl` sind noch nicht installiert.
- Die APT-Simulation für `python3.12-venv` plant genau diese drei neuen Pakete, keine Upgrades und keine Entfernungen.
- ROCm 7.2.1 erkennt `gfx1101` und die AMD Radeon RX 7700 XT; OpenCL erkennt genau ein GPU-Gerät.

## Aktuelle Primärquellenprüfung

AMD empfiehlt für Ubuntu 24.04 und ROCm 7.2.1 Python 3.12 sowie die vier Wheels PyTorch 2.9.1, Torchvision 0.24.0, Torchaudio 2.9.0 und Triton 3.5.1 direkt von `repo.radeon.com`.

Das aktuelle offizielle Chatterbox-`pyproject.toml` steht weiterhin auf Version 0.1.7 und verlangt unter Python 3.14 weiterhin exakt `torch==2.6.0` und `torchaudio==2.6.0`. Eine normale Chatterbox-Installation könnte deshalb den AMD-validierten Frameworksatz ersetzen und ist in U3C verboten.

Quellen:

- https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-pytorch.html
- https://github.com/resemble-ai/chatterbox/blob/master/pyproject.toml

## U3C1 – Venv-Voraussetzung

Der vorbereitete Helfer `scripts/u3c1_prepare_venv.sh` erlaubt ausschließlich:

- `python3-pip-whl` 24.0+dfsg-1ubuntu1.3 – 1.706.638 Byte
- `python3-setuptools-whl` 68.1.2-2ubuntu1.2 – 716.284 Byte
- `python3.12-venv` 3.12.3-1ubuntu0.16 – 5.682 Byte
- **zusammen höchstens 2.428.604 Byte / 0,002429 GB Paketnutzlast**

Danach wird lokal `/home/tille/Projects/TilleVoiceStudio/.venv` erstellt. Das Verzeichnis verwendet keine System-Site-Packages. Noch keine Python-Pakete werden aus dem Internet installiert.

U3C1 benötigt vor der Ausführung eine ausdrückliche:

1. **DOWNLOAD-FREIGABE bis 2.428.604 Byte**
2. **SYSTEMÄNDERUNGS-FREIGABE für genau die drei APT-Pakete**

## U3C2 – AMD-Frameworksatz

Erst nach U3C1-PASS und einer eigenen Freigabe sind vorgesehen:

| Wheel | Byte |
|---|---:|
| PyTorch 2.9.1 + ROCm 7.2.1 | 1.650.644.034 |
| Torchvision 0.24.0 + ROCm 7.2.1 | 2.946.390 |
| Triton 3.5.1 + ROCm 7.2.1 | 287.563.448 |
| Torchaudio 2.9.0 + ROCm 7.2.1 | 488.612 |
| **Summe** | **1.941.642.484** |

Vor U3C2 wird ein eigener Helfer mit Hash-/Größenkontrollen, isoliertem Wheel-Verzeichnis und einer Prüfung der zusätzlichen Python-Laufzeitabhängigkeiten erstellt. Für U3C2 liegt noch keine Freigabe vor.

## Abnahmekriterien für U3C2

- `torch.__version__` entspricht 2.9.1 + ROCm 7.2.1.
- `torch.version.hip` ist gesetzt.
- `torch.cuda.is_available()` liefert `True`.
- Gerät 0 ist die AMD Radeon RX 7700 XT.
- Eine kleine Tensoroperation läuft auf der GPU und liefert ein korrektes Ergebnis.
- Torch/Torchaudio werden nicht auf 2.6.0 geändert.

## Stoppbedingungen

Sofort stoppen bei:

- zusätzlichen APT-Paketen, Upgrades oder Entfernungen in U3C1;
- Überschreitung der jeweiligen Downloadgrenze;
- Installation in das System-Python;
- einer ungeplanten Chatterbox- oder Modelldatei;
- einer Abhängigkeitsauflösung, die Torch oder Torchaudio 2.6.0 verlangt;
- fehlender GPU-Erkennung nach der Frameworkinstallation.
