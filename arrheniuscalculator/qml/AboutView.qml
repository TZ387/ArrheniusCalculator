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
            BackButton { stackView: root.stackView }

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
        RuleLine { topMargin: 0; bottomMargin: 0 }

        // ── Content card ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.colorSurface
            border.color: Style.colorBorder
            border.width: 1
            radius: 8

            Flickable {
                anchors {
                    fill: parent
                    margins: 24
                }
                clip: true
                contentHeight: aboutText.implicitHeight
                contentWidth: width   // fixed, no loop possible

                TextEdit {
                    id: aboutText
                    width: parent.width   // parent is Flickable — stable, not circular
                    textFormat: Text.RichText
                    text: qsTr(
                        "<b>Arrhenius Calculator</b><br><br>" +
                        "A simple QML-based application for calculating the Arrhenius integral " +
                        "across different scenarios, including discrete data and analytical functions.<br><br>" +
                        "Using the application is straightforward: click the Launch button and choose " +
                        "the type of calculation you want. Then enter the required parameters and press " +
                        "Calculate.<br><br>" +
                        "You can hover over the question mark icons for additional guidance where needed."
                    )
                    font {
                        family: "Georgia"
                        pixelSize: 14
                    }
                    color: Style.colorText
                    wrapMode: TextEdit.WordWrap
                    readOnly: true
                    selectByMouse: true
                    selectByKeyboard: true
                    selectedTextColor: Style.colorSurface
                    selectionColor: Style.colorAccent

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                    }

                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: qsTr("Copy")
                            enabled: aboutText.selectedText.length > 0
                            onTriggered: aboutText.copy()
                        }
                    }
                }
            }
        }

        // Small bottom padding
        Item { Layout.preferredHeight: 4 }
    }
}
