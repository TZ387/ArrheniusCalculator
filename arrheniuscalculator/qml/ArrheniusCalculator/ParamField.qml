import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// A labelled text-input field used for Arrhenius parameters.
//
// Properties:
//   label        - field label shown above the input
//   defaultValue - initial text in the input
//   value        - alias to the live text (read/write)
//   labelWrap    - set to Text.WordWrap for long labels (e.g. T(t) expressions)
ColumnLayout {
    id: pf

    property string label:        ""
    property string defaultValue: ""
    property alias  value:        pfInput.text
    property int    labelWrap:    Text.NoWrap

    spacing: 4
    Layout.fillWidth: true

    Text {
        text:      pf.label
        font      { family: "Georgia"; pixelSize: 13 }
        color:     Style.colorMuted
        wrapMode:  pf.labelWrap
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 34
        radius: 5
        color: Style.colorSurface
        border.color: pfInput.activeFocus ? Style.colorAccent : Style.colorBorder
        border.width: pfInput.activeFocus ? 1.5 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }

        TextInput {
            id: pfInput
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            verticalAlignment: TextInput.AlignVCenter
            text:  pf.defaultValue
            font  { family: "Georgia"; pixelSize: 15 }
            color: Style.colorText
            selectByMouse: true
        }
    }
}
