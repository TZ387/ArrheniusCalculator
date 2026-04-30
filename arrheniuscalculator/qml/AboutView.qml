import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── About view ────────────────────────────────────────────────────────────
Item {
    id: root

    // Grab the StackView from the parent hierarchy
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

            // Back button (icon-style arrow)
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
                text: qsTr("About")
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

        // ── Content card ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.colorSurface
            border.color: Style.colorBorder
            border.width: 1
            radius: 8

            ScrollView {
                anchors {
                    fill: parent
                    margins: 24
                }
                clip: true
                contentWidth: availableWidth

                Text {
                    width: parent.width
                    text: qsTr(
                        "Arrhenius Calculator\n\n" +
                        "(pre-release)\n\n" +
                        "About & instructions — yet to be added.\n\n" +
                        "This section will describe the purpose of the tool, " +
                        "the Arrhenius equation background, how to enter data, " +
                        "and how to interpret results."
                    )
                    font {
                        family: "Georgia"
                        pixelSize: 14
                    }
                    color: Style.colorText
                    lineHeight: 1.6
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Small bottom padding
        Item { Layout.preferredHeight: 4 }
    }
}
