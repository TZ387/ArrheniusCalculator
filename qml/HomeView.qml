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

        // ── Image placeholder ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.colorSurface
            border.color: Style.colorBorder
            border.width: 1
            radius: 8

            // Dashed inner border hint
            Rectangle {
                anchors { fill: parent; margins: 10 }
                color: "transparent"
                border.color: Style.colorBorder
                border.width: 1
                radius: 4
                opacity: 0.6
            }

            Column {
                anchors.centerIn: parent
                spacing: 10

                Canvas {
                    width: 56
                    height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = Style.colorBorder
                        ctx.lineWidth = 1.5
                        ctx.beginPath()
                        ctx.rect(2, 2, width - 4, height - 4)
                        ctx.fillStyle = Style.colorBg
                        ctx.fill()
                        ctx.stroke()
                        ctx.fillStyle = Style.colorBorder
                        ctx.beginPath()
                        ctx.moveTo(8, height - 10)
                        ctx.lineTo(28, 16)
                        ctx.lineTo(48, height - 10)
                        ctx.closePath()
                        ctx.fill()
                        ctx.beginPath()
                        ctx.arc(44, 13, 7, 0, 2 * Math.PI)
                        ctx.fill()
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Image placeholder")
                    font { family: "Georgia"; pixelSize: 13; italic: true }
                    color: Style.colorMuted
                }
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
                onClicked: {
                    // TODO: implement launch logic
                }
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
