import QtQuick
import QtQuick.Controls

// ── Reusable button ───────────────────────────────────────────────────────
// Usage:
//   AppButton { text: "Launch"; primary: true;  onClicked: { … } }
//   AppButton { text: "About";  primary: false; onClicked: { … } }
AbstractButton {
    id: control

    // true  → filled accent button
    // false → outlined secondary button
    property bool primary: true

    implicitHeight: 42
    implicitWidth: 120

    // ── Visuals ───────────────────────────────────────────────────────────
    background: Rectangle {
        radius: 6
        color: {
            if (control.primary) {
                return control.hovered
                       ? ApplicationWindow.window.colorAccentHov
                       : ApplicationWindow.window.colorAccent
            }
            return control.hovered
                   ? Qt.rgba(0.17, 0.29, 0.49, 0.08)   // very light tint on hover
                   : "transparent"
        }
        border.color: ApplicationWindow.window.colorAccent
        border.width: 1.5

        Behavior on color {
            ColorAnimation { duration: 130 }
        }
    }

    contentItem: Text {
        text: control.text
        font {
            family: "Georgia"
            pixelSize: 14
            weight: Font.Medium
            letterSpacing: 0.3
        }
        color: control.primary
               ? ApplicationWindow.window.colorSurface
               : ApplicationWindow.window.colorAccent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Scale micro-interaction on press
    scale: control.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 80 }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
        onPressed: control.pressed = true
        onReleased: control.pressed = false
        onEntered: control.hovered = true
        onExited: control.hovered = false
    }
}
