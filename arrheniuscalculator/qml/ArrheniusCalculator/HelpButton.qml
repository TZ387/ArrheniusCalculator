import QtQuick
import QtQuick.Controls
import ArrheniusCalculator

// ── Generic help button (?-circle) with a styled tooltip ─────────────────────
// Usage:
//   HelpButton {
//       tooltipText: "Explain something useful here."
//       tooltipTimeout: 8000   // optional, default 8000 ms
//   }
Rectangle {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property alias tooltipText:    tip.text
    property int   tooltipTimeout: 8000

    // ── Geometry ──────────────────────────────────────────────────────────────
    implicitWidth:  28
    implicitHeight: 28
    radius: 14

    // ── Visuals ───────────────────────────────────────────────────────────────
    color: "transparent"
    border.color: hover.hovered ? Style.colorAccent : Style.colorMuted
    border.width: 1.5
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: "?"
        font { family: "Georgia"; pixelSize: 14; weight: Font.Medium }
        color: hover.hovered ? Style.colorAccent : Style.colorMuted
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    HoverHandler { id: hover; cursorShape: Qt.WhatsThisCursor }

    ToolTip {
        visible: hover.hovered
        delay:   400
        timeout: root.tooltipTimeout

        contentItem: Text {
            id: tip
            font { family: "Georgia"; pixelSize: 12 }
            color: "#222222"
            wrapMode: Text.WordWrap
        }

        background: Rectangle {
            color:        "#FFFBC8"
            border.color: "#C8B400"
            border.width: 1
            radius: 4
        }
    }
}
