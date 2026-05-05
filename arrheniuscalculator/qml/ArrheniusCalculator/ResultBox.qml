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
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        verticalAlignment: TextInput.AlignVCenter
        text:  parent.value
        font  { family: "Georgia"; pixelSize: 15; italic: parent.value === "—" }
        color: parent.value === "—" ? Style.colorMuted : Style.colorAccent
        readOnly: true
        selectByMouse: true
    }
}
