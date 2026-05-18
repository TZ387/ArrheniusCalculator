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
        // The Item fills the layout cell; the Image inside uses PreserveAspectFit
        // so its painted area may be smaller than the cell (letterboxed). The
        // Rectangle is sized to paintedWidth/paintedHeight so the border hugs
        // only the visible picture, not the empty letterbox space.
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Image {
                id: introImage
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: Qt.resolvedUrl("ArrheniusCalculator/Intro_Image.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Rectangle {
                anchors.centerIn: parent
                width:  introImage.paintedWidth
                height: introImage.paintedHeight
                color: "transparent"
                border.color: "#031297"   // dark blue frame
                border.width: 2.5
                radius: 8
            }
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
