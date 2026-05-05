import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// A read-only result display box.
//
// Properties:
//   value - formatted result string; defaults to "—" (shown dimmed/italic)
Rectangle {
    property string value: "—"

    Layout.fillWidth: true
    implicitHeight: 34
    radius: 5
    color: Style.colorBg
    border.color: Style.colorBorder
    border.width: 1

    TextInput {
        id: resultInput
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        verticalAlignment: TextInput.AlignVCenter
        text:  parent.value
        font  { family: "Georgia"; pixelSize: 15; italic: parent.value === "—" }
        color: parent.value === "—" ? Style.colorMuted : Style.colorAccent
        readOnly: true
        selectByMouse: true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                resultInput.forceActiveFocus()
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: "Copy"
            enabled: resultInput.selectedText.length > 0
            onTriggered: resultInput.copy()
        }
        MenuSeparator {}
        MenuItem {
            text: "Select All"
            enabled: resultInput.text.length > 0 && resultInput.text !== "—"
            onTriggered: resultInput.selectAll()
        }
    }
}