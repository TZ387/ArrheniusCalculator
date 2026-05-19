import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator
import "ArrheniusCalc.js" as Calc

// ── Text-data Arrhenius calculation view ──────────────────────────────────
// Formula:  Ω = Σᵢ A · exp(−Eₐ / (R · Tᵢ)) · Δtᵢ
//           where Δtᵢ = tᵢ₊₁ − tᵢ  (forward difference on the t list)
// VHS:      (1/Ω_vhs)^p = (1/Ω₁)^p + (1/Ω₂)^p
Item {
    id: root

    property StackView stackView: StackView.view as StackView

    // ── State ─────────────────────────────────────────────────────────────
    property real omega1:   NaN
    property real omega2:   NaN
    property real omegaVHS: NaN

    property bool useCelsius1: false
    property bool useCelsius2: false

    // ── Scroll wrapper ────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.vertical.width: 12
        ScrollBar.vertical.contentItem: Rectangle {
            color: Style.colorScrollBar
        }

        ColumnLayout {
            width: parent.width
            anchors {
                left:   parent.left
                right:  parent.right
                margins: 32
            }
            spacing: 0

            // ── Header ────────────────────────────────────────────────────
            Item { Layout.preferredHeight: 28 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                BackButton { stackView: root.stackView }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Text data calculation")
                    font { family: "Georgia"; pixelSize: 22; weight: Font.DemiBold; letterSpacing: 0.4 }
                    color: Style.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                // Help button — explains the discrete summation method
                HelpButton {
                    tooltipTimeout: 12000
                    tooltipText: "Ω = Σᵢ A · exp(−Eₐ / (R · Tᵢ)) · Δtᵢ\n\n"
                               + "Each time step contributes one Arrhenius term.\n"
                               + "Δtᵢ is the forward difference tᵢ₊₁ − tᵢ; the last\n"
                               + "point reuses the previous interval width.\n\n"
                               + "t [s] and T [K] are entered as lists of numbers.\n"
                               + "Values may be separated by spaces, commas (,),\n"
                               + "semicolons (;), or pipes (|) in any combination.\n"
                               + "Both lists must contain the same number of values.\n\n"
                               + "Steps where T ≤ 0 K contribute zero to the sum."
                }
            }

            // ── Summation formula display ─────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.topMargin: 10
                Layout.bottomMargin: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        id: mainLeft
                        text: "Ω = Σ A · e"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                    }

                    Text {
                        text: "−Eₐ/(R·Tᵢ)"
                        font { family: "Georgia"; pixelSize: 12; italic: true }
                        color: Style.colorText
                        anchors.bottom: mainLeft.top
                        anchors.bottomMargin: -mainLeft.height * 0.38
                    }

                    Text {
                        text: " · Δtᵢ"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                    }
                }
            }

            RuleLine {}

            // ══════════════════════════════════════════════════════════════
            // SET 1
            // ══════════════════════════════════════════════════════════════
            SectionLabel { text: "Set 1" }
            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: a1Field;  label: "A [1/s]";    defaultValue: "3.1e98" }
                ParamField { id: ea1Field; label: "Eₐ [J/mol]"; defaultValue: "6.28e5" }
            }

            Item { Layout.preferredHeight: 10 }

            ParamField {
                Layout.fillWidth: true
                id: tList1Field
                label: "t [s]  — list of values"
                defaultValue: "1 2 3 4 5 6"
            }

            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ParamField {
                    Layout.fillWidth: true
                    id: tTempList1Field
                    label: root.useCelsius1 ? "T [°C]  — list of values"
                                            : "T [K]  — list of values"
                    defaultValue: "310, 320; 330 340, 350 360"
                }

                CelsiusCheckBox {
                    id: celsius1Check
                    checked: root.useCelsius1
                    onToggled: root.useCelsius1 = checked
                }
            }

            Item { Layout.preferredHeight: 14 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                AppButton {
                    text: qsTr("Calculate")
                    primary: true
                    implicitWidth: 110
                    onClicked: {
                        var tList1  = Calc.parseList(tList1Field.value)
                        var rawT1   = Calc.parseList(tTempList1Field.value)
                        var kelvin1 = root.useCelsius1
                            ? rawT1.map(function(v) { return v + 273.15 })
                            : rawT1
                        var A1  = Calc.parseVal(a1Field.value)
                        var Ea1 = Calc.parseVal(ea1Field.value)

                        var v1 = Calc.validateTextData(A1, Ea1, tList1, kelvin1)
                        status1.severity = v1.severity
                        status1.message  = v1.message

                        if (v1.ok)
                            root.omega1 = Calc.calcOmegaTextData(A1, Ea1, tList1, kelvin1)
                        else
                            root.omega1 = NaN
                    }
                }

                Text {
                    text: "Ω₁ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: Calc.formatResult(root.omega1) }
            }

            CalcStatusBar {
                id: status1
                Layout.fillWidth: true
                Layout.topMargin: 8
            }

            // Separator
            DividerLine {}

            // ══════════════════════════════════════════════════════════════
            // SET 2
            // ══════════════════════════════════════════════════════════════
            SectionLabel { text: "Set 2" }
            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: a2Field;  label: "A [1/s]";    defaultValue: "1.45e4" }
                ParamField { id: ea2Field; label: "Eₐ [J/mol]"; defaultValue: "1.03e5" }
            }

            Item { Layout.preferredHeight: 10 }

            ParamField {
                Layout.fillWidth: true
                id: tList2Field
                label: "t [s]  — list of values"
                defaultValue: "1 2 3 4 5 6"
            }

            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ParamField {
                    Layout.fillWidth: true
                    id: tTempList2Field
                    label: root.useCelsius2 ? "T [°C]  — list of values"
                                            : "T [K]  — list of values"
                    defaultValue: "310 320 330 340 350 360"
                }

                CelsiusCheckBox {
                    id: celsius2Check
                    checked: root.useCelsius2
                    onToggled: root.useCelsius2 = checked
                }
            }

            Item { Layout.preferredHeight: 14 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                AppButton {
                    text: qsTr("Calculate")
                    primary: true
                    implicitWidth: 110
                    onClicked: {
                        var tList2  = Calc.parseList(tList2Field.value)
                        var rawT2   = Calc.parseList(tTempList2Field.value)
                        var kelvin2 = root.useCelsius2
                            ? rawT2.map(function(v) { return v + 273.15 })
                            : rawT2
                        var A2  = Calc.parseVal(a2Field.value)
                        var Ea2 = Calc.parseVal(ea2Field.value)

                        var v2 = Calc.validateTextData(A2, Ea2, tList2, kelvin2)
                        status2.severity = v2.severity
                        status2.message  = v2.message

                        if (v2.ok)
                            root.omega2 = Calc.calcOmegaTextData(A2, Ea2, tList2, kelvin2)
                        else
                            root.omega2 = NaN
                    }
                }

                Text {
                    text: "Ω₂ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: Calc.formatResult(root.omega2) }
            }

            CalcStatusBar {
                id: status2
                Layout.fillWidth: true
                Layout.topMargin: 8
            }

            // Separator
            DividerLine {}

            // ══════════════════════════════════════════════════════════════
            // VHS CALCULATION
            // ══════════════════════════════════════════════════════════════
            VhsSection {
                omega1:   root.omega1
                omega2:   root.omega2
                onOmegaVHSChanged: root.omegaVHS = omegaVHS
            }

            Item { Layout.preferredHeight: 36 }
        }
    }
}
