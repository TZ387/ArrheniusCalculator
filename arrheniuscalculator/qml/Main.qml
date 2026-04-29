import QtQuick
import QtQuick.Controls
import ArrheniusCalculator

ApplicationWindow {
    id: root

    minimumWidth: 480
    minimumHeight: 560
    width: 480
    height: 560
    visible: true
    title: qsTr("Arrhenius Calculator")

    background: Rectangle { color: Style.colorBg }

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
