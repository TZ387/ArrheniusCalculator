import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── Calculation selector view ─────────────────────────────────────────────
Item {
    id: root

    property StackView stackView: StackView.view as StackView

    ColumnLayout {
        anchors {
            fill: parent
            margins: 36
        }
        spacing: 24

        // ── Header row: back button + title ───────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: backBtn
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: backMouse.containsMouse
                       ? Style.colorAccent
                       : "transparent"
                border.color: Style.colorAccent
                border.width: 1.5

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: 16
                    color: backMouse.containsMouse
                           ? Style.colorSurface
                           : Style.colorAccent

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.stackView.pop()
                }
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Select Calculation")
                font {
                    family: "Georgia"
                    pixelSize: 26
                    weight: Font.DemiBold
                    letterSpacing: 0.5
                }
                color: Style.colorText
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Thin accent rule
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: Style.colorAccent
            opacity: 0.25
            radius: 1
        }

        // ── Calculation type buttons ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Basic calculation")
                primary: false
                onClicked: { /* TODO */ }
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Function calculation")
                primary: false
                onClicked: { /* TODO */ }
            }
        }

        // ── Spacer ────────────────────────────────────────────────────────
        Item { Layout.fillHeight: true }
    }
}
