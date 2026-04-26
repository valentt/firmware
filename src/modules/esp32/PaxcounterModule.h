#pragma once

#include "ProtobufModule.h"
#include "configuration.h"
#if defined(ARCH_ESP32) && !MESHTASTIC_EXCLUDE_PAXCOUNTER
#include "../mesh/generated/meshtastic/paxcount.pb.h"
#include "NodeDB.h"
#include <libpax_api.h>

/**
 * Wrapper module for the estimate passenger (PAX) count library (https://github.com/dbinfrago/libpax) which
 * implements the core functionality of the ESP32 Paxcounter project (https://github.com/cyberman54/ESP32-Paxcounter)
 */
class PaxcounterModule : private concurrency::OSThread, public ProtobufModule<meshtastic_Paxcount>
{
    bool firstTime = true;
    bool reportedDataSent = true;

    static void handlePaxCounterReportRequest();

  public:
    PaxcounterModule();

  protected:
    struct count_payload_t count_from_libpax = {0, 0, 0};
    virtual int32_t runOnce() override;
    bool sendInfo(NodeNum dest = NODENUM_BROADCAST);
    virtual bool handleReceivedProtobuf(const meshtastic_MeshPacket &mp, meshtastic_Paxcount *p) override;
    virtual meshtastic_MeshPacket *allocReply() override;
    // Modified: allow PAX with BLE enabled (custom Heltec V2.1 build)
    // Original required BLE+WiFi off for promiscuous mode scanning
    bool isActive() { return moduleConfig.paxcounter.enabled; }
#if HAS_SCREEN
    virtual bool wantUIFrame() override { return isActive(); }
    virtual void drawFrame(OLEDDisplay *display, OLEDDisplayUiState *state, int16_t x, int16_t y) override;
#endif
};

extern PaxcounterModule *paxcounterModule;
#endif
