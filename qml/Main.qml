import QtQuick
import QtQuick.Controls
// import QtQuick.Layouts

ApplicationWindow {
    id: root

    minimumWidth: 480
    minimumHeight: 560
    width: 480
    height: 560
    visible: true
    title: qsTr("Arrhenius Calculator")

    // ── Palette ────────────────────────────────────────────────────────────
    readonly property color colorBg:         "#F5F2EC"
    readonly property color colorSurface:    "#FFFFFF"
    readonly property color colorBorder:     "#D6CFC4"
    readonly property color colorAccent:     "#2C4A7C"
    readonly property color colorAccentHov:  "#1E3560"
    readonly property color colorText:       "#1A1A2E"
    readonly property color colorMuted:      "#7A7A8C"

    background: Rectangle { color: root.colorBg }

    // ── Navigation stack ──────────────────────────────────────────────────
    StackView {
        id: stack
        anchors.fill: parent

        // No built-in transition animation needed — define a clean fade
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }
        popEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }

        initialItem: HomeView { }
    }
}
