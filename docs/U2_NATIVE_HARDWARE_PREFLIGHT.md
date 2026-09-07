# U2 – Nativer Hardware-Preflight

- Datum: 2026-09-06
- Ergebnis: **PASS**
- Arbeitsweise: lokale Diagnose; keine Paketinstallation und kein Download

## Ziel

U2 bestätigt die native Ubuntu-Basis, die AMD-GPU-Erkennung und den effektiven Benutzerzugriff auf die Compute-Geräte, bevor ROCm oder Python-GPU-Pakete installiert werden.

## Ergebnisse

| Prüfung | Ergebnis | Status |
|---|---|---|
| Betriebssystem | Ubuntu 24.04.4 LTS, x86_64 | PASS |
| Kernel | `6.17.0-14-generic` | PASS |
| Bootmodus | UEFI | PASS |
| Secure Boot | aktiviert | PASS |
| CPU | AMD Ryzen 5 7500F, 6 Kerne/12 Threads | PASS |
| Arbeitsspeicher | 30 GiB RAM, 8 GiB Swap | PASS |
| Ubuntu-Systempartition | 97 GiB ext4, 75 GiB frei zum Prüfzeitpunkt | PASS |
| GPU | AMD Radeon RX 7700 XT, PCI-ID `1002:747e` | PASS |
| Kernel-Treiber | `amdgpu` geladen und dem GPU-Gerät zugeordnet | PASS |
| VRAM | 12.272 MiB vom Kernel initialisiert | PASS |
| KFD | dGPU-Knoten erfolgreich angelegt | PASS |
| GPU-Ziel | `gfx_target_version 110001`, entsprechend `gfx1101` | PASS |
| Render-Gerät | `/dev/dri/renderD128` vorhanden; benutzerseitig `read write` bestätigt | PASS |
| Compute-Gerät | `/dev/kfd` vorhanden; nach Zugriffsbereinigung benutzerseitig `read write` bestätigt | PASS |
| Python-Basis | Python 3.12.3 vorhanden | PASS |
| ROCm-Werkzeuge | noch nicht vorhanden | ERWARTET |

## Diagnosehinweise

Der Kernel meldet die erfolgreiche Initialisierung von `amdgpu`, DRM und KFD. Im Kernelprotokoll erschien einmal `Failed to setup vendor infoframe on connector HDMI-A-2: -22`. Da der Ubuntu-Desktop läuft und GPU, DRM sowie KFD vollständig initialisiert wurden, wird dies für U2 als nicht blockierender Anzeigehinweis dokumentiert. Falls am betreffenden HDMI-Ausgang später Bild- oder Audioaussetzer auftreten, ist er gezielt erneut zu untersuchen.

Die Codex-Ausführungsumgebung blendet `/dev/dri` und `/dev/kfd` aus. Deshalb wurden Existenz und effektive Benutzerrechte zusätzlich vom Benutzer in einem normalen Ubuntu-Terminal geprüft und bestätigt.

## Abschlusskriterien

- Native Ubuntu-Installation und Zielkernel laufen.
- RX 7700 XT, `amdgpu`, KFD und `gfx1101` sind bestätigt.
- Der Benutzer besitzt effektiven Lese- und Schreibzugriff auf `/dev/kfd` und `/dev/dri/renderD128`.
- Es wurde weder ROCm installiert noch ein Paket heruntergeladen.

U2 ist damit **PASS**.

## Nächster Übergabepunkt

Vor der ROCm-Installation ist eine eigene Planungs- und Freigaberunde erforderlich:

1. Aktuelle offizielle AMD-Kompatibilitäts- und Installationsdokumentation erneut prüfen.
2. Festlegen, ob der vorhandene Ubuntu-`amdgpu`-Treiber beibehalten wird und welche ROCm-Komponenten tatsächlich benötigt werden.
3. Secure-Boot-/DKMS-Auswirkungen vor jeder Treiberänderung klären.
4. Downloadgrößen und 20-GB-Projektbudget aktualisieren.
5. Separate DOWNLOAD- und gegebenenfalls SYSTEMÄNDERUNGS-FREIGABE einholen.

Bis dahin keine ROCm-, AMD-SMI-, PyTorch-, Chatterbox- oder Modellinstallation starten.
