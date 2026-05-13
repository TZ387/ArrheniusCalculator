import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator
import "../ArrheniusCalc.js" as Calc

// ── Reusable VHS section ──────────────────────────────────────────────────
// Renders the full VHS block: header, formula, p field, Calculate button
// and result box. Place it directly inside the parent ColumnLayout.
//
// Usage:
//   VhsSection {
//       omega1:   root.omega1
//       omega2:   root.omega2
//       omegaVHS: root.omegaVHS   // bind two-way or read the signal
//       onOmegaVHSChanged: root.omegaVHS = omegaVHS
//   }
Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    property real omega1:   NaN
    property real omega2:   NaN
    property real omegaVHS: NaN

    // Lay out as a ColumnLayout child
    Layout.fillWidth: true
    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right }
        spacing: 0

        // ── Header: label + spacer + help button ──────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            SectionLabel { text: "VHS calculation" }

            Item { Layout.fillWidth: true }

            HelpButton {
                tooltipText: "A simple formula taken from\n"
                           + "\"Variable heat shock response model for medical laser procedures\"\n"
                           + "article, whose intention is to generalise the Arrhenius calculation\n"
                           + "for cases where you have short temperature peaks."
            }
        }

        // ── Formula: (1/Ωᵥₕₛ)ᵖ = (1/Ω₁)ᵖ + (1/Ω₂)ᵖ ─────────────────────
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            Layout.topMargin: 8
            Layout.bottomMargin: 14

            Row {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    id: vhsBase
                    text: "(1/Ωᵥₕₛ)"
                    font { family: "Georgia"; pixelSize: 20; italic: true; weight: Font.Bold }
                    color: Style.colorText
                }
                Text {
                    text: "p"
                    font { family: "Georgia"; pixelSize: 12; italic: true; weight: Font.Bold }
                    color: Style.colorText
                    anchors.bottom: vhsBase.top
                    anchors.bottomMargin: -vhsBase.height * 0.4
                }

                Text {
                    id: vhsMid
                    text: "  =  (1/Ω₁)"
                    font { family: "Georgia"; pixelSize: 20; italic: true; weight: Font.Bold }
                    color: Style.colorText
                }
                Text {
                    text: "p"
                    font { family: "Georgia"; pixelSize: 12; italic: true; weight: Font.Bold }
                    color: Style.colorText
                    anchors.bottom: vhsMid.top
                    anchors.bottomMargin: -vhsMid.height * 0.4
                }

                Text {
                    id: vhsRight
                    text: "  +  (1/Ω₂)"
                    font { family: "Georgia"; pixelSize: 20; italic: true; weight: Font.Bold }
                    color: Style.colorText
                }
                Text {
                    text: "p"
                    font { family: "Georgia"; pixelSize: 12; italic: true; weight: Font.Bold }
                    color: Style.colorText
                    anchors.bottom: vhsRight.top
                    anchors.bottomMargin: -vhsRight.height * 0.4
                }
            }
        }

        // ── p parameter ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            ParamField { id: pField; label: "p"; defaultValue: "0.15" }
            Item { Layout.fillWidth: true }
        }

        Item { Layout.preferredHeight: 10 }

        // ── Calculate button + result ─────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            AppButton {
                text: qsTr("Calculate")
                primary: true
                implicitWidth: 110
                onClicked: {
                    root.omegaVHS = Calc.calcOmegaVHS(
                        root.omega1,
                        root.omega2,
                        Calc.parseVal(pField.value)
                    )
                }
            }

            Text {
                text: "Ωᵥₕₛ ="
                font { family: "Georgia"; pixelSize: 16 }
                color: Style.colorMuted
            }

            ResultBox { value: Calc.formatResult(root.omegaVHS) }
        }
    }
}
