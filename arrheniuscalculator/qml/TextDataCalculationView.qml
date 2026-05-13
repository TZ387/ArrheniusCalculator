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

                Rectangle {
                    id: backBtn
                    implicitWidth:  36
                    implicitHeight: 36
                    radius: 18
                    color: backMouse.containsMouse ? Style.colorAccent : "transparent"
                    border.color: Style.colorAccent
                    border.width: 1.5
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        font.pixelSize: 16
                        color: backMouse.containsMouse ? Style.colorSurface : Style.colorAccent
                        Behavior on color { ColorAnimation { duration: 120 } }
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.topMargin: 4
                Layout.bottomMargin: 20
                color: Style.colorAccent
                opacity: 0.25
                radius: 1
            }

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
                        var rawT1 = Calc.parseList(tTempList1Field.value)
                        var kelvin1 = root.useCelsius1
                            ? rawT1.map(function(v) { return v + 273.15 })
                            : rawT1
                        root.omega1 = Calc.calcOmegaTextData(
                            Calc.parseVal(a1Field.value),
                            Calc.parseVal(ea1Field.value),
                            Calc.parseList(tList1Field.value),
                            kelvin1
                        )
                    }
                }

                Text {
                    text: "Ω₁ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: Calc.formatResult(root.omega1) }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                color: Style.colorBorder
                opacity: 0.6
            }

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
                        var rawT2 = Calc.parseList(tTempList2Field.value)
                        var kelvin2 = root.useCelsius2
                            ? rawT2.map(function(v) { return v + 273.15 })
                            : rawT2
                        root.omega2 = Calc.calcOmegaTextData(
                            Calc.parseVal(a2Field.value),
                            Calc.parseVal(ea2Field.value),
                            Calc.parseList(tList2Field.value),
                            kelvin2
                        )
                    }
                }

                Text {
                    text: "Ω₂ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: Calc.formatResult(root.omega2) }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                color: Style.colorBorder
                opacity: 0.6
            }

            // ══════════════════════════════════════════════════════════════
            // VHS CALCULATION
            // ══════════════════════════════════════════════════════════════
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

            // VHS formula with real superscripts
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: pField; label: "p"; defaultValue: "0.15" }
                Item { Layout.fillWidth: true }
            }

            Item { Layout.preferredHeight: 10 }

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

            Item { Layout.preferredHeight: 36 }
        }
    }
}
