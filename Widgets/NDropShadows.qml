import QtQuick
import QtQuick.Effects
import qs.Commons
import qs.Services.Power

// Unified shadow system
Item {
  id: root

  required property var source

  property bool autoPaddingEnabled: false

  layer.enabled: Settings.data.general.enableShadows && !PowerProfileService.noctaliaPerformanceMode
  layer.effect: MultiEffect {
    source: root.source
    shadowEnabled: true
    blurMax: Style.shadowBlurMax
    shadowBlur: 0.0  // Sharp shadow for hard appearance
    shadowOpacity: 0.85  // High opacity for visibility
    shadowColor: Color.mSecondary  // Secondary color instead of black
    shadowHorizontalOffset: 3  // Fixed horizontal offset
    shadowVerticalOffset: 3  // Fixed vertical offset
    autoPaddingEnabled: root.autoPaddingEnabled
  }
}
