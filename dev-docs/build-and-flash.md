# Build i Flash procedura

## Preduvjeti
pip install platformio meshtastic esptool

## Build
cd C:/Users/Valent/code/meshtastic-firmware
pio run -e heltec-v2_1

## Flash (clean install)
python -m esptool --chip esp32 --port COM4 --baud 921600 erase-flash
python -m esptool --chip esp32 --port COM4 --baud 921600 write-flash 0x0 .pio/build/heltec-v2_1/*.factory.bin

## Flash (update, cuva BLE bondove)
python -m esptool --chip esp32 --port COM4 --baud 921600 write-flash 0x10000 .pio/build/heltec-v2_1/*[!factory].bin

## Post-flash konfiguracija
meshtastic --port COM4 --set lora.region 3
meshtastic --port COM4 --set paxcounter.enabled true
meshtastic --port COM4 --set paxcounter.paxcounter_update_interval 15

## Serijski monitor
meshtastic --port COM4 --listen
