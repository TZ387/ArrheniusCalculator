import QtQuick
import QtQuick.Layouts
import ArrheniusCalculator

// ── Section divider ───────────────────────────────────────────────────────
// Used between content sections (e.g. Set 1 / Set 2 / VHS).
// Usage:
//   DividerLine {}
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 1
    Layout.topMargin:    20
    Layout.bottomMargin: 20

    color:   Style.colorBorder
    opacity: 0.6
}
