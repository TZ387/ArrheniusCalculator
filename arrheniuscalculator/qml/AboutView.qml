import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── About view ────────────────────────────────────────────────────────────
Item {
    id: root

    // Grab the StackView from the parent hierarchy
    property StackView stackView: StackView.view as StackView

    // ── Responsive scale helpers ──────────────────────────────────────────
    // Width is the primary driver — this view is horizontally laid out and
    // width is the more stable dimension as the window resizes.
    readonly property real refSize: width

    // Outer margin: ~4 % of width, clamped 20–56 px
    readonly property real outerMargin: Math.max(20, Math.min(56, refSize * 0.04))

    // Spacing between layout rows: ~2.5 % of width, clamped 14–36 px
    readonly property real rowSpacing: Math.max(14, Math.min(36, refSize * 0.025))

    // Title font: ~3.5 % of width, clamped 22–40 px
    readonly property real titlePixelSize: Math.round(Math.max(22, Math.min(40, refSize * 0.035)))

    // Body font: ~2 % of width, clamped 15–24 px
    readonly property real bodyPixelSize: Math.round(Math.max(15, Math.min(24, refSize * 0.02)))

    // Card inner padding: ~3 % of shorter edge, clamped 12–36 px
    readonly property real cardPadding: Math.max(12, Math.min(36, refSize * 0.03))

    // Card corner radius: ~1.2 % of shorter edge, clamped 4–16 px
    readonly property real cardRadius: Math.max(4, Math.min(16, refSize * 0.012))

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.outerMargin
        }
        spacing: root.rowSpacing

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
                    pixelSize: root.titlePixelSize
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
            radius: root.cardRadius

            Flickable {
                anchors {
                    fill: parent
                    margins: root.cardPadding
                }
                clip: true
                contentHeight: aboutText.implicitHeight
                contentWidth: width

                TextEdit {
                    id: aboutText
                    width: parent.width
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
                        pixelSize: root.bodyPixelSize
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
        Item { Layout.preferredHeight: root.rowSpacing / 3 }
    }
}
