import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── Home / Main view ──────────────────────────────────────────────────────
Item {
    id: root

    // Attached property — available automatically when this item is inside a StackView
    property StackView stackView: StackView.view as StackView

    // ── Layout ────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors {
            fill: parent
            margins: 36
        }
        spacing: 28

        // ── Title ─────────────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: qsTr("Arrhenius Calculator")
            font {
                family: "Georgia"
                pixelSize: 26
                weight: Font.DemiBold
                letterSpacing: 0.5
            }
            color: Style.colorText
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // Thin accent rule under the title
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: Style.colorAccent
            opacity: 0.25
            radius: 1
        }

        // ── Image ─────────────────────────────────────────────────────────
        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: Qt.resolvedUrl("ArrheniusCalculator/Intro_Image.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        // ── Button row ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Launch")
                primary: true
                onClicked: root.stackView.push(Qt.resolvedUrl("OptionView.qml"))
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("About")
                primary: false
                onClicked: root.stackView.push(Qt.resolvedUrl("AboutView.qml"))
            }
        }

        Item { Layout.preferredHeight: 4 }
    }
}
