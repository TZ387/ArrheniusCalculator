import QtQuick
import QtQuick.Controls
import ArrheniusCalculator

// ── Reusable "Use °C" checkbox ────────────────────────────────────────────
// Emits toggled(bool checked) so callers can bind their useCelsius property.
CheckBox {
    id: root

    text: qsTr("Use °C")
    font.pixelSize: 13
    palette.windowText: Style.colorText
}
