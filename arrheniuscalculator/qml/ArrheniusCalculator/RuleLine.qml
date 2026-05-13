import QtQuick
import QtQuick.Layouts
import ArrheniusCalculator

// ── Thin accent rule ──────────────────────────────────────────────────────
// Used under page headers and formula displays.
// Usage:
//   RuleLine {}
//   RuleLine { topMargin: 10; bottomMargin: 20 }
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 2
    Layout.topMargin:    topMargin
    Layout.bottomMargin: bottomMargin

    property int topMargin:    4
    property int bottomMargin: 20

    color:   Style.colorAccent
    opacity: 0.25
    radius:  1
}
