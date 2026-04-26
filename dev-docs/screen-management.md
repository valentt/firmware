# Meshtastic OLED Screen Management

## Kako se ekrani dodaju/sakrivaju

### Runtime konfiguracija (bez rebuilda)
\`\`\`bash
# Compass/North
meshtastic --port COM4 --set display.compass_north_top false

# Screen carousel interval
meshtastic --port COM4 --set display.auto_screen_carousel_secs 10

# Screen brightness
meshtastic --port COM4 --set display.screen_brightness 200

# Screen timeout
meshtastic --port COM4 --set display.screen_on_secs 60
\`\`\`

### Build-time konfiguracija (treba rebuild)
Svaki modul kontrolira svoj ekran kroz \`wantUIFrame()\`:
\`\`\`cpp
// U ModuleName.h:
virtual bool wantUIFrame() override { return isActive(); }
virtual void drawFrame(OLEDDisplay *display, OLEDDisplayUiState *state, int16_t x, int16_t y) override;
\`\`\`

Ako \`wantUIFrame()\` vraca false, ekran se NE prikazuje u rotaciji.

### GPS ekrani
GPS ekrani (sateliti, bearing, location) se kontroliraju s:
- \`MESHTASTIC_EXCLUDE_GPS=1\` u variant.h (kompletno iskljucuje GPS modul)
- \`HAS_GPS=0\` u variant.h
- \`position.gps_mode=DISABLED\` (runtime, ali ne sakriva uvijek UI)

### PAX Counter ekran
PAX Counter ekran se prikazuje samo kad:
- \`MESHTASTIC_EXCLUDE_PAXCOUNTER\` NIJE definiran (ili =0)
- PaxcounterModule.cpp je u build_src_filter
- libpax library je u lib_deps
- \`isActive()\` vraca true (paxcounter.enabled + BLE/WiFi uvjeti)

### Registracija ekrana u Screen.cpp
Screen.cpp automatski prikuplja frame callbacks od svih modula koji imaju \`wantUIFrame()=true\`.
Nema potrebe za rucnom registracijom.

### Dashboard (prvi ekran)
Dashboard layout je hardkodiran u \`Screen.cpp\` → \`drawNodeInfo()\`.
Za promjenu (npr. PAX umjesto GPS satelita) treba editirati source.

## Korisni flagovi za sakrivanje modula

| Flag | Sto sakriva |
|------|-------------|
| MESHTASTIC_EXCLUDE_GPS | GPS ekrani (sateliti, bearing, location) |
| MESHTASTIC_EXCLUDE_PAXCOUNTER | PAX Counter ekran |
| HAS_SCREEN=0 | SVE ekrane |
| MESHTASTIC_EXCLUDE_BLUETOOTH | BLE konfiguracija |
