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
                        root.omega1 = Calc.calcOmegaBasic(
                            Calc.parseVal(a1Field.value),
                            Calc.parseVal(ea1Field.value),
                            t1K,
                            Calc.parseVal(dt1Field.value)
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
                        root.omega2 = Calc.calcOmegaBasic(
                            Calc.parseVal(a2Field.value),
                            Calc.parseVal(ea2Field.value),
                            t2K,
                            Calc.parseVal(dt2Field.value)
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
