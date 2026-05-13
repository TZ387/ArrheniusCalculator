import QtQuick
import QtQuick.Controls
import ArrheniusCalculator

// ── Reusable back button (← circle) ──────────────────────────────────────
// Usage:
//   BackButton { stackView: root.stackView }
Rectangle {
    id: root

    property StackView stackView

    implicitWidth:  36
    implicitHeight: 36
    radius:         18

    color: backMouse.containsMouse ? Style.colorAccent : "transparent"
    border.color: Style.colorAccent
    border.width: 1.5

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: "←"
        font.pixelSize: 16
        color: backMouse.containsMouse ? Style.colorSurface : Style.colorAccent
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: backMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.stackView.pop()
    }
}
