import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator
import "ArrheniusCalc.js" as Calc

// ── Function Arrhenius calculation view ───────────────────────────────────
// Formula:  Ω = ∫[t1→t2] A · exp(−Ea / (R · T(t))) dt
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
                    id: funcCalcTitle
                    Layout.fillWidth: true
                    text: qsTr("Function calculation")
                    font { family: "Georgia"; pixelSize: 22; weight: Font.DemiBold; letterSpacing: 0.4 }
                    color: Style.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                // Help button — explains the numerical integration method
                HelpButton {
                    tooltipTimeout: 10000
                    tooltipText: "The integral  Ω = ∫ A·exp(−Eₐ/(R·T(t))) dt  is evaluated\n"
                               + "numerically using adaptive Simpson's rule.\n\n"
                               + "The integration interval [t₁, t₂] is subdivided recursively\n"
                               + "until the estimated error falls below a tolerance that scales\n"
                               + "with the interval length (≈ 10⁻⁷ · |t₂ − t₁|, min 10⁻⁹).\n\n"
                               + "T(t) must be a valid JavaScript expression in the variable t.\n"
                               + "Standard Math functions (Math.exp, Math.sin, Math.pow, …)\n"
                               + "are supported. Samples where T(t) ≤ 0 contribute zero."
                }
            }

            // ── Integral formula display ──────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Layout.topMargin: 10
                Layout.bottomMargin: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        id: fmlOmega
                        text: "Ω = "
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                        anchors.verticalCenter: integralSign.verticalCenter
                    }

                    Item {
                        id: integralSign
                        width: limitCol.width
                        height: limitCol.height

                        Column {
                            id: limitCol
                            spacing: 0
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                text: "t₂"
                                font { family: "Georgia"; pixelSize: 15; italic: true }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "∫"
                                font { family: "Georgia"; pixelSize: 38 }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "t₁"
                                font { family: "Georgia"; pixelSize: 15; italic: true }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Text {
                        id: fmlAe
                        text: " A · e"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                        anchors.verticalCenter: integralSign.verticalCenter
                    }

                    Text {
                        text: "−Eₐ/(R·T(t))"
                        font { family: "Georgia"; pixelSize: 14; italic: true }
                        color: Style.colorText
                        anchors.bottom: fmlAe.top
                        anchors.bottomMargin: -fmlAe.height * 0.38
                    }

                    Text {
                        text: " dt"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                        anchors.verticalCenter: integralSign.verticalCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.topMargin: 10
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
                ParamField {
                    id: t1s1Field
                    label: "t₁ [s]"
                    defaultValue: "0"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
                }
            }

            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField {
                    id: tf1Field
                    label: root.useCelsius1 ? "T(t) [°C]  — time-dependent function"
                                            : "T(t) [K]  — time-dependent function"
                    defaultValue: "318.15 + 20*Math.exp(-t/60)"
                    labelWrap: Text.WordWrap
                }
                ParamField {
                    id: t2s1Field
                    label: "t₂ [s]"
                    defaultValue: "60"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Item { Layout.fillWidth: true }
                CheckBox {
                    text: qsTr("Use °C")
                    checked: root.useCelsius1
                    onToggled: root.useCelsius1 = checked
                    font.pixelSize: 13
                    palette.windowText: Style.colorText
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
                        var rawFunc1 = Calc.buildTFunc(tf1Field.value)
                        var tFunc1 = (root.useCelsius1 && rawFunc1 !== null)
                            ? function(t) { return rawFunc1(t) + 273.15 }
                            : rawFunc1
                        root.omega1 = Calc.calcOmegaFunc(
                            Calc.parseVal(a1Field.value),
                            Calc.parseVal(ea1Field.value),
                            tFunc1,
                            Calc.parseVal(t1s1Field.value),
                            Calc.parseVal(t2s1Field.value)
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
                ParamField {
                    id: t1s2Field
                    label: "t₁ [s]"
                    defaultValue: "0"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
                }
            }

            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField {
                    id: tf2Field
                    label: root.useCelsius2 ? "T(t) [°C]  — time-dependent function"
                                            : "T(t) [K]  — time-dependent function"
                    defaultValue: "318.15"
                    labelWrap: Text.WordWrap
                }
                ParamField {
                    id: t2s2Field
                    label: "t₂ [s]"
                    defaultValue: "60"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Item { Layout.fillWidth: true }
                CheckBox {
                    text: qsTr("Use °C")
                    checked: root.useCelsius2
                    onToggled: root.useCelsius2 = checked
                    font.pixelSize: 13
                    palette.windowText: Style.colorText
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
                        var rawFunc2 = Calc.buildTFunc(tf2Field.value)
                        var tFunc2 = (root.useCelsius2 && rawFunc2 !== null)
                            ? function(t) { return rawFunc2(t) + 273.15 }
                            : rawFunc2
                        root.omega2 = Calc.calcOmegaFunc(
                            Calc.parseVal(a2Field.value),
                            Calc.parseVal(ea2Field.value),
                            tFunc2,
                            Calc.parseVal(t1s2Field.value),
                            Calc.parseVal(t2s2Field.value)
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

            // VHS formula with superscripts
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
