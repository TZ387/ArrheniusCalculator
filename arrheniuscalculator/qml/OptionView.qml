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

            BackButton { stackView: root.stackView }

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
        RuleLine { topMargin: 0; bottomMargin: 0 }

        // ── Calculation type buttons ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Basic calculation")
                primary: false
                onClicked: root.stackView.push(Qt.resolvedUrl("BasicCalculationView.qml"))
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Function calculation")
                primary: false
                onClicked: root.stackView.push(Qt.resolvedUrl("FunctionCalculationView.qml"))
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Calculation from text data")
                primary: false
                onClicked: root.stackView.push(Qt.resolvedUrl("TextDataCalculationView.qml"))
            }
        }

        // ── Spacer ────────────────────────────────────────────────────────
        Item { Layout.fillHeight: true }
    }
}
