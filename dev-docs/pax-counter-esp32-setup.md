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

## Buduci plan: BLE State Machine
BLE_PAIRING (60s) -> MESH_MODE (connected) -> PAX_MODE (scanning)
Spec: development/plan/meshtastic-ble-pax-state-machine-spec.md
