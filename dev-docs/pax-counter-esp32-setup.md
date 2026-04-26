# PAX Counter na ESP32 Classic (Heltec V2.1)

## Problem
PAX Counter je EXCLUDED po defaultu za ESP32 classic zbog RAM ogranicenja.

## Tri prepreke i rjesenja

### 1. Build flag override
esp32.ini definira -DMESHTASTIC_EXCLUDE_PAXCOUNTER=1.
Override u heltec platformio.ini: -D MESHTASTIC_EXCLUDE_PAXCOUNTER=0

### 2. Source filter
esp32.ini excludea -<modules/esp32/PaxcounterModule.cpp>.
Override: +<modules/esp32/PaxcounterModule.cpp>

### 3. libpax library
Dodati u lib_deps: https://github.com/dbinfrago/libpax

## BLE konflikt
PAX koristi libpax BLE scan koji konflikira s Meshtastic NimBLE.
Rjesenje: MESHTASTIC_EXCLUDE_BLUETOOTH=1 (PAX dobiva ekskluzivni BLE pristup)
WiFi scan: disabled (wificounter=0) jer OOM na ESP32 s BLE.

## BLE State Machine (commit dfc988a, 26.04.2026)

States:
- BLE_PAIRING: NimBLE aktivan 60s, Meshtastic app moze se spojiti
- MESH_MODE: BLE connected, mesh aktivan, PAX neaktivan
- PAX_MODE: NimBLE deinit, libpax BLE scan aktivan

Transition pravila:
- Boot -> BLE_PAIRING (60s window)
- BLE_PAIRING + 60s timeout, no connection -> PAX_MODE
- BLE_PAIRING + connection -> MESH_MODE
- MESH_MODE + disconnect + 60s bez reconnect -> PAX_MODE
- PAX_MODE: ONE-WAY, treba reboot za BLE pairing window opet

Implementacija:
- src/modules/esp32/PaxcounterModule.cpp: startPaxMode() funkcija
- runOnce(): provjera firstTime + uptime > 60s -> startPaxMode()
- NimBLE deinit: nimbleBluetooth->deinit() prije libpax init
- 500ms delay izmedju deinit i libpax init (BLE controller release)

Test rezultati T1: PASS (uptime 62s switch, libpax broji BLE OK)
Test T2/T3: PENDING (treba Meshtastic app za pairing test)

Spec: development/plan/meshtastic-ble-pax-state-machine-spec.md
