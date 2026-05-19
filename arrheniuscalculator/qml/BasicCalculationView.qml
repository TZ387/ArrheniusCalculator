import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator
import "ArrheniusCalc.js" as Calc

// ── Basic Arrhenius calculation view ─────────────────────────────────────
// Formula:  Ω = A · exp(−Ea / (R · T)) · Δt
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
                    text: qsTr("Basic calculation")
                    font { family: "Georgia"; pixelSize: 22; weight: Font.DemiBold; letterSpacing: 0.4 }
                    color: Style.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // ── Arrhenius formula with real superscript ───────────────────
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
                        text: "Ω = A · e"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                    }

                    Text {
                        text: "−Eₐ/(R·T)"
                        font { family: "Georgia"; pixelSize: 12; italic: true }
                        color: Style.colorText
                        anchors.bottom: mainLeft.top
                        anchors.bottomMargin: -mainLeft.height * 0.38
                    }

                    Text {
                        text: " · Δt"
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: t1Field;  label: root.useCelsius1 ? "T [°C]" : "T [K]"; defaultValue: "45+273.15" }
                ParamField { id: dt1Field; label: "Δt [s]"; defaultValue: "1"         }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Item { Layout.fillWidth: true }
                CelsiusCheckBox {
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
                        var t1K = Calc.parseVal(t1Field.value)
                        if (root.useCelsius1) t1K += 273.15
                        var A1  = Calc.parseVal(a1Field.value)
                        var Ea1 = Calc.parseVal(ea1Field.value)
                        var dt1 = Calc.parseVal(dt1Field.value)

                        var v1 = Calc.validateBasic(A1, Ea1, t1K, dt1)
                        status1.severity = v1.severity
                        status1.message  = v1.message

                        if (v1.ok)
                            root.omega1 = Calc.calcOmegaBasic(A1, Ea1, t1K, dt1)
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: t2Field;  label: root.useCelsius2 ? "T [°C]" : "T [K]"; defaultValue: "45+273.15" }
                ParamField { id: dt2Field; label: "Δt [s]"; defaultValue: "1"         }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Item { Layout.fillWidth: true }
                CelsiusCheckBox {
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
                        var t2K = Calc.parseVal(t2Field.value)
                        if (root.useCelsius2) t2K += 273.15
                        var A2  = Calc.parseVal(a2Field.value)
                        var Ea2 = Calc.parseVal(ea2Field.value)
                        var dt2 = Calc.parseVal(dt2Field.value)

                        var v2 = Calc.validateBasic(A2, Ea2, t2K, dt2)
                        status2.severity = v2.severity
                        status2.message  = v2.message

                        if (v2.ok)
                            root.omega2 = Calc.calcOmegaBasic(A2, Ea2, t2K, dt2)
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
