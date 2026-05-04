import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── Basic Arrhenius calculation view ─────────────────────────────────────
// Formula:  Ω = A · exp(−Ea / (R · T)) · Δt
// VHS:      (1/Ω_vhs)^p = (1/Ω₁)^p + (1/Ω₂)^p
Item {
    id: root

    property StackView stackView: StackView.view as StackView

    // ── Fix 1: enlarge the ApplicationWindow when this view is pushed ─────
    Component.onCompleted: {
        var w = Window.window
        if (w) {
            if (w.width  < 600) w.width  = 600
            if (w.height < 920) w.height = 920
        }
    }

    // ── Constants ─────────────────────────────────────────────────────────
    readonly property real gasConstant: 8.314462618   // J/(mol·K)

    // ── Helpers ───────────────────────────────────────────────────────────

    // Fix 2: evaluate simple arithmetic before converting to float.
    // Supports +, -, *, / and scientific notation (45+273.15, 6.2e88 …).
    function parseVal(text) {
        var s = text.trim()
        if (s === "") return 0.0
        try {
            // Function constructor evaluates a JS expression safely from
            // user-supplied text (no external injection; same trust level as
            // the rest of the QML user-input fields).
            var result = Function('"use strict"; return (' + s + ')')()
            var v = Number(result)
            return isFinite(v) ? v : 0.0
        } catch (e) {
            var v2 = parseFloat(s)
            return isNaN(v2) ? 0.0 : v2
        }
    }

    function calcOmega(A, Ea, T, dt) {
        if (T <= 0) return NaN
        return A * Math.exp(-Ea / (gasConstant * T)) * dt
    }

    function formatResult(val) {
        if (isNaN(val) || !isFinite(val)) return "—"
        if (Math.abs(val) >= 1e6 || (Math.abs(val) < 1e-3 && val !== 0))
            return val.toExponential(4)
        return val.toPrecision(6)
    }

    // ── State ─────────────────────────────────────────────────────────────
    property real omega1:   NaN
    property real omega2:   NaN
    property real omegaVHS: NaN

    // ── Scroll wrapper ────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

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

            // ── Fix 4: Arrhenius formula with real superscript ────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.topMargin: 10
                Layout.bottomMargin: 2

                // "Ω = A · e" at full size, then the exponent raised above
                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        id: mainLeft
                        text: "Ω = A · e"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                    }

                    // Superscript: sits with its bottom aligned to the top
                    // third of the main text glyphs
                    Text {
                        text: "−Eₐ/(R·T)"
                        font { family: "Georgia"; pixelSize: 12; italic: true }
                        color: Style.colorText
                        // Raise by roughly half the main cap-height
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
                // Fix 2: default shows arithmetic expression the user can edit
                ParamField { id: t1Field;  label: "T [K]";  defaultValue: "45+273.15" }
                ParamField { id: dt1Field; label: "Δt [s]"; defaultValue: "1"         }
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
                        root.omega1 = root.calcOmega(
                            root.parseVal(a1Field.value),
                            root.parseVal(ea1Field.value),
                            root.parseVal(t1Field.value),
                            root.parseVal(dt1Field.value)
                        )
                    }
                }

                Text {
                    text: "Ω₁ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: root.formatResult(root.omega1) }
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
                ParamField { id: t2Field;  label: "T [K]";  defaultValue: "45+273.15" }
                ParamField { id: dt2Field; label: "Δt [s]"; defaultValue: "1"         }
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
                        root.omega2 = root.calcOmega(
                            root.parseVal(a2Field.value),
                            root.parseVal(ea2Field.value),
                            root.parseVal(t2Field.value),
                            root.parseVal(dt2Field.value)
                        )
                    }
                }

                Text {
                    text: "Ω₂ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: root.formatResult(root.omega2) }
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

                // Help button — hover shows tooltip, no click action
                Rectangle {
                    id: helpBtn
                    implicitWidth: 28; implicitHeight: 28
                    radius: 14
                    color: "transparent"
                    border.color: helpHover.hovered ? Style.colorAccent : Style.colorMuted
                    border.width: 1.5
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        font { family: "Georgia"; pixelSize: 14; weight: Font.Medium }
                        color: helpHover.hovered ? Style.colorAccent : Style.colorMuted
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    HoverHandler { id: helpHover; cursorShape: Qt.WhatsThisCursor }

                    ToolTip {
                        visible: helpHover.hovered
                        // Small delay so it doesn't flash on quick pass-overs
                        delay: 400
                        timeout: 8000
                        contentItem: Text {
                            text: "A simple formula taken from\n"
                                + "\"Variable heat shock response model for medical laser procedures\"\n"
                                + "article, whose intention is to generalise the Arrhenius calculation\n"
                                + "for cases where you have short temperature peaks."
                            font { family: "Georgia"; pixelSize: 12 }
                            color: "#222222"
                            wrapMode: Text.WordWrap
                        }
                        background: Rectangle {
                            color: "#FFFBC8"          // classic tooltip yellow
                            border.color: "#C8B400"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }

            // ── Fix 4: VHS formula with real superscripts ─────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                Layout.topMargin: 8
                Layout.bottomMargin: 14

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    // (1/Ω_vhs)
                    Text {
                        id: vhsBase
                        text: "(1/Ωᵥₕₛ)"
                        font { family: "Georgia"; pixelSize: 20; italic: true; weight: Font.Bold }
                        color: Style.colorText
                    }
                    // ^p
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

            // Fix 3: p field on its own row (half-width)
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField { id: pField; label: "p"; defaultValue: "0.15" }
                Item { Layout.fillWidth: true }   // takes the other half
            }

            Item { Layout.preferredHeight: 10 }

            // Fix 3: Calculate + Ω_vhs result on the row below
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                AppButton {
                    text: qsTr("Calculate")
                    primary: true
                    implicitWidth: 110
                    onClicked: {
                        var p = root.parseVal(pField.value)
                        if (isNaN(root.omega1) || isNaN(root.omega2) ||
                            root.omega1 === 0  || root.omega2 === 0  || p === 0) {
                            root.omegaVHS = NaN
                            return
                        }
                        var inv = Math.pow(1.0 / root.omega1, p) +
                                  Math.pow(1.0 / root.omega2, p)
                        root.omegaVHS = 1.0 / Math.pow(inv, 1.0 / p)
                    }
                }

                Text {
                    text: "Ωᵥₕₛ ="
                    font { family: "Georgia"; pixelSize: 16 }
                    color: Style.colorMuted
                }

                ResultBox { value: root.formatResult(root.omegaVHS) }
            }

            Item { Layout.preferredHeight: 36 }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // Reusable inline components
    // ─────────────────────────────────────────────────────────────────────

    component SectionLabel: Text {
        font { family: "Georgia"; pixelSize: 15; weight: Font.DemiBold }
        color: Style.colorText
    }

    // Fix 2: inputMethodHints removed so arithmetic expressions are typeable
    component ParamField: ColumnLayout {
        id: pf
        property string label: ""
        property string defaultValue: ""
        property alias  value: pfInput.text
        spacing: 4
        Layout.fillWidth: true

        Text {
            text: pf.label
            font { family: "Georgia"; pixelSize: 14 }
            color: Style.colorMuted
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
                text: pf.defaultValue
                font { family: "Georgia"; pixelSize: 15 }
                color: Style.colorText
                selectByMouse: true
                // inputMethodHints intentionally omitted — allows +−*/
            }
        }
    }

    component ResultBox: Rectangle {
        property string value: "—"
        Layout.fillWidth: true
        implicitHeight: 34
        radius: 5
        color: Style.colorBg
        border.color: Style.colorBorder
        border.width: 1

        Text {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            verticalAlignment: Text.AlignVCenter
            text: parent.value
            font { family: "Georgia"; pixelSize: 15; italic: parent.value === "—" }
            color: parent.value === "—" ? Style.colorMuted : Style.colorAccent
            elide: Text.ElideRight
        }
    }
}
