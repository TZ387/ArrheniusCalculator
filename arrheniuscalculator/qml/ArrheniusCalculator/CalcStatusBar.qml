import QtQuick
import QtQuick.Layouts
import ArrheniusCalculator

// ── CalcStatusBar ─────────────────────────────────────────────────────────
// Slim status banner shown after each Calculate press.
//
// Properties:
//   severity  — "ok" | "warn" | "error"
//   message   — text to display; bar is hidden when empty
//
// Usage: place directly after the Calculate button RowLayout, before
// the DividerLine.  Set Layout.fillWidth: true and Layout.topMargin
// at the usage site.
Rectangle {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    property string severity: "ok"    // "ok" | "warn" | "error"
    property string message:  ""

    // ── Derived colours ───────────────────────────────────────────────────
    readonly property color _bg:     severity === "ok"    ? "#EAF3E8"
                                   : severity === "warn"  ? "#FDF6E3"
                                                          : "#FDECEA"
    readonly property color _border: severity === "ok"    ? "#7CB87A"
                                   : severity === "warn"  ? "#C8A84B"
                                                          : "#C0544A"
    readonly property color _text:   severity === "ok"    ? "#2E6B2C"
                                   : severity === "warn"  ? "#7A5C00"
                                                          : "#8B2020"
    readonly property string _icon:  severity === "ok"    ? "✓"
                                   : severity === "warn"  ? "⚠"
                                                          : "✕"

    // ── Geometry ──────────────────────────────────────────────────────────
    // Note: Layout.fillWidth and Layout.topMargin must be set at the usage
    // site, not here, because attached properties require a ColumnLayout
    // parent to be present at the time of object creation.

    visible:        message !== ""
    implicitHeight: visible ? layout.implicitHeight + 12 : 0
    height:         implicitHeight
    radius:         5
    color:          _bg
    border.color:   _border
    border.width:   1

    // ── Content ───────────────────────────────────────────────────────────
    // RowLayout lets the message Text claim all remaining width via
    // Layout.fillWidth, giving wrapMode a well-defined constraint so the
    // rectangle always grows to fit the text rather than clipping it.
    RowLayout {
        id: layout
        anchors {
            left:           parent.left
            right:          parent.right
            verticalCenter: parent.verticalCenter
            leftMargin:     12
            rightMargin:    12
        }
        spacing: 8

        Text {
            text:             root._icon
            color:            root._text
            font {            pixelSize: 15; weight: Font.Bold }
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 1
        }

        Text {
            text:             root.message
            color:            root._text
            font {            pixelSize: 14; family: "Georgia" }
            wrapMode:         Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
