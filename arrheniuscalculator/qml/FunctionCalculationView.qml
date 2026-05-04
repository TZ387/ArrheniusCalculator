import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ArrheniusCalculator

// ── Function Arrhenius calculation view ───────────────────────────────────
// Formula:  Ω = ∫[t1→t2] A · exp(−Ea / (R · T(t))) dt
// VHS:      (1/Ω_vhs)^p = (1/Ω₁)^p + (1/Ω₂)^p
Item {
    id: root

    property StackView stackView: StackView.view as StackView

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

    // Evaluate a numeric expression (may contain +, -, *, /, Math.*, etc.)
    function parseVal(text) {
        var s = text.trim()
        if (s === "") return 0.0
        try {
            var result = Function('"use strict"; return (' + s + ')')()
            var v = Number(result)
            return isFinite(v) ? v : 0.0
        } catch (e) {
            var v2 = parseFloat(s)
            return isNaN(v2) ? 0.0 : v2
        }
    }

    // Build a function of t from a user-supplied expression string.
    // The expression may use 't' as the independent variable (time) and
    // standard JS/Math functions: Math.sin, Math.exp, Math.pow, etc.
    // Returns a JS function(t) → number, or null on parse error.
    function buildTFunc(expr) {
        var s = expr.trim()
        if (s === "") return null
        try {
            // Wrap in a function body that accepts 't'
            var f = Function('"use strict"; return function(t) { return (' + s + '); }')()
            // Quick sanity check: must return a finite number for t=0
            var probe = Number(f(0))
            if (!isFinite(probe)) return null
            return f
        } catch (e) {
            return null
        }
    }

    // Adaptive Simpson's rule numerical integration.
    // Integrates func(t) from a to b with absolute tolerance tol.
    // Returns NaN if func is invalid or limits are bad.
    function adaptiveSimpson(func, a, b, tol, maxDepth) {
        if (func === null || !isFinite(a) || !isFinite(b)) return NaN

        function simpsonStep(fa, fm, fb, h) {
            return (h / 6.0) * (fa + 4.0 * fm + fb)
        }

        function recurse(a, b, fa, fm, fb, whole, depth) {
            var m1 = (a + (a + b) / 2.0) / 2.0
            var m2 = ((a + b) / 2.0 + b) / 2.0
            var h  = (b - a) / 2.0
            var fm1 = func(m1)
            var fm2 = func(m2)
            var mid = (a + b) / 2.0
            var left  = simpsonStep(fa,  fm1, fm,  h / 2.0)
            var right = simpsonStep(fm,  fm2, fb,  h / 2.0)
            var delta = left + right - whole
            if (depth >= maxDepth || Math.abs(delta) <= 15.0 * tol) {
                return left + right + delta / 15.0
            }
            return recurse(a,   mid, fa,  fm1, fm,  left,  depth + 1) +
                   recurse(mid, b,   fm,  fm2, fb,  right, depth + 1)
        }

        var fa  = func(a)
        var fb  = func(b)
        var mid = (a + b) / 2.0
        var fm  = func(mid)
        var h   = b - a
        var whole = simpsonStep(fa, fm, fb, h)
        if (!isFinite(fa) || !isFinite(fb) || !isFinite(fm)) return NaN
        return recurse(a, b, fa, fm, fb, whole, 0)
    }

    // Main calculation: Ω = ∫[t1→t2] A·exp(−Ea/(R·T(t))) dt
    function calcOmega(A, Ea, Tfunc, t1, t2) {
        if (Tfunc === null) return NaN
        if (!isFinite(t1) || !isFinite(t2)) return NaN

        var integrand = function(t) {
            var T = Tfunc(t)
            if (T <= 0) return 0.0
            return A * Math.exp(-Ea / (gasConstant * T))
        }

        // Tolerance scales with the interval length; cap at 1e-9
        var tol = Math.max(1e-9, Math.abs(t2 - t1) * 1e-7)
        return adaptiveSimpson(integrand, t1, t2, tol, 30)
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
                    id: funcCalcTitle
                    Layout.fillWidth: true
                    text: qsTr("Function calculation")
                    font { family: "Georgia"; pixelSize: 22; weight: Font.DemiBold; letterSpacing: 0.4 }
                    color: Style.colorText
                    verticalAlignment: Text.AlignVCenter
                }

                // Help button — explains the numerical integration method
                Rectangle {
                    id: integralHelpBtn
                    implicitWidth: 28; implicitHeight: 28
                    radius: 14
                    color: "transparent"
                    border.color: integralHelpHover.hovered ? Style.colorAccent : Style.colorMuted
                    border.width: 1.5
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        font { family: "Georgia"; pixelSize: 14; weight: Font.Medium }
                        color: integralHelpHover.hovered ? Style.colorAccent : Style.colorMuted
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    HoverHandler { id: integralHelpHover; cursorShape: Qt.WhatsThisCursor }

                    ToolTip {
                        visible: integralHelpHover.hovered
                        delay: 400
                        timeout: 10000
                        contentItem: Text {
                            text: "The integral  Ω = ∫ A·exp(−Eₐ/(R·T(t))) dt  is evaluated\n"
                                + "numerically using adaptive Simpson's rule.\n\n"
                                + "The integration interval [t₁, t₂] is subdivided recursively\n"
                                + "until the estimated error falls below a tolerance that scales\n"
                                + "with the interval length (≈ 10⁻⁷ · |t₂ − t₁|, min 10⁻⁹).\n\n"
                                + "T(t) must be a valid JavaScript expression in the variable t.\n"
                                + "Standard Math functions (Math.exp, Math.sin, Math.pow, …)\n"
                                + "are supported. Samples where T(t) ≤ 0 contribute zero."
                            font { family: "Georgia"; pixelSize: 12 }
                            color: "#222222"
                            wrapMode: Text.WordWrap
                        }
                        background: Rectangle {
                            color: "#FFFBC8"
                            border.color: "#C8B400"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Layout.topMargin: 10
                Layout.bottomMargin: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    // "Ω = " label
                    Text {
                        id: fmlOmega
                        text: "Ω = "
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                        anchors.verticalCenter: integralSign.verticalCenter
                    }

                    // Integral sign with limits rendered via stacked items
                    Item {
                        id: integralSign
                        width: limitCol.width
                        height: limitCol.height

                        Column {
                            id: limitCol
                            spacing: 0
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Upper limit
                            Text {
                                text: "t₂"
                                font { family: "Georgia"; pixelSize: 15; italic: true }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            // The ∫ sign itself
                            Text {
                                text: "∫"
                                font { family: "Georgia"; pixelSize: 38 }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            // Lower limit
                            Text {
                                text: "t₁"
                                font { family: "Georgia"; pixelSize: 15; italic: true }
                                color: Style.colorText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Space + "A · e"
                    Text {
                        id: fmlAe
                        text: " A · e"
                        font { family: "Georgia"; pixelSize: 22; italic: true }
                        color: Style.colorText
                        anchors.verticalCenter: integralSign.verticalCenter
                    }

                    // Superscript exponent: −Eₐ/(R·T(t))
                    Text {
                        text: "−Eₐ/(R·T(t))"
                        font { family: "Georgia"; pixelSize: 14; italic: true }
                        color: Style.colorText
                        anchors.bottom: fmlAe.top
                        anchors.bottomMargin: -fmlAe.height * 0.38
                    }

                    // " dt"
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

            // Row 1: A | Eₐ | t₁
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

            // Row 2: T(t) — fills remaining space | t₂
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField {
                    id: tf1Field
                    label: "T(t) [K]  — time-dependent function"
                    defaultValue: "318.15 + 20*Math.exp(-t/60)"
                }
                ParamField {
                    id: t2s1Field
                    label: "t₂ [s]"
                    defaultValue: "60"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
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
                        var Tfunc = root.buildTFunc(tf1Field.value)
                        root.omega1 = root.calcOmega(
                            root.parseVal(a1Field.value),
                            root.parseVal(ea1Field.value),
                            Tfunc,
                            root.parseVal(t1s1Field.value),
                            root.parseVal(t2s1Field.value)
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

            // Row 1: A | Eₐ | t₁
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

            // Row 2: T(t) | t₂
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                ParamField {
                    id: tf2Field
                    label: "T(t) [K]  — time-dependent function"
                    defaultValue: "318.15"
                }
                ParamField {
                    id: t2s2Field
                    label: "t₂ [s]"
                    defaultValue: "60"
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
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
                        var Tfunc = root.buildTFunc(tf2Field.value)
                        root.omega2 = root.calcOmega(
                            root.parseVal(a2Field.value),
                            root.parseVal(ea2Field.value),
                            Tfunc,
                            root.parseVal(t1s2Field.value),
                            root.parseVal(t2s2Field.value)
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
            // VHS CALCULATION  (identical to BasicCalculationView)
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                SectionLabel { text: "VHS calculation" }

                Item { Layout.fillWidth: true }

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
                            color: "#FFFBC8"
                            border.color: "#C8B400"
                            border.width: 1
                            radius: 4
                        }
                    }
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
    // Reusable inline components  (identical to BasicCalculationView)
    // ─────────────────────────────────────────────────────────────────────

    component SectionLabel: Text {
        font { family: "Georgia"; pixelSize: 15; weight: Font.DemiBold }
        color: Style.colorText
    }

    component ParamField: ColumnLayout {
        id: pf
        property string label: ""
        property string defaultValue: ""
        property alias  value: pfInput.text
        spacing: 4
        Layout.fillWidth: true

        Text {
            text: pf.label
            font { family: "Georgia"; pixelSize: 13 }
            color: Style.colorMuted
            wrapMode: Text.WordWrap
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
                text: pf.defaultValue
                font { family: "Georgia"; pixelSize: 15 }
                color: Style.colorText
                selectByMouse: true
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

        TextInput {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            verticalAlignment: TextInput.AlignVCenter
            text: parent.value
            font { family: "Georgia"; pixelSize: 15; italic: parent.value === "—" }
            color: parent.value === "—" ? Style.colorMuted : Style.colorAccent
            readOnly: true          // prevents editing
            selectByMouse: true     // enables Ctrl+C and mouse selection
        }
    }
}
