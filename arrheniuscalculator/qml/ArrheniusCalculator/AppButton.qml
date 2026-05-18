import QtQuick
import QtQuick.Controls
import ArrheniusCalculator

// ── Reusable button ───────────────────────────────────────────────────────
// Usage:
//   AppButton { text: "Launch"; primary: true;  onClicked: { … } }
//   AppButton { text: "About";  primary: false; onClicked: { … } }
AbstractButton {
    id: control

    // true  → filled accent button
    // false → outlined secondary button
    property bool primary: true

    // Implicit size acts as a minimum / natural size.
    // When placed in a Layout with fillWidth/fillHeight, the actual
    // width/height will be larger and drive the font scaling below.
    implicitWidth: 120
    implicitHeight: 42

    hoverEnabled: true
    HoverHandler { cursorShape: Qt.PointingHandCursor }

    // ── Visuals ───────────────────────────────────────────────────────────
    background: Rectangle {
        radius: control.height * 0.14   // radius scales with button height
        color: {
            if (control.primary) {
                return control.hovered
                       ? Style.colorAccentHov
                       : Style.colorAccent
            }
            return control.hovered
                   ? Qt.rgba(0.17, 0.29, 0.49, 0.08)
                   : "transparent"
        }
        border.color: Style.colorAccent
        border.width: Math.max(1, control.height * 0.035)  // border scales too

        Behavior on color {
            ColorAnimation { duration: 130 }
        }
    }

    contentItem: Text {
        text: control.text
        font {
            family: "Georgia"
            // Font scales with button height; clamp between 11 and 32 px
            pixelSize: Math.round(Math.max(11, Math.min(32, control.height * 0.33)))
            weight: Font.Medium
            letterSpacing: 0.3
        }
        color: control.primary
               ? Style.colorSurface
               : Style.colorAccent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Scale micro-interaction on press
    scale: control.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 80 }
    }
}
