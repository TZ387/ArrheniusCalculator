import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle  # ← add this import

def main() -> None:
    QQuickStyle.setStyle("Fusion")  # ← must be before QGuiApplication(...)
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Arrhenius Calculator")
    app.setOrganizationName("ArrheniusCalc")
    engine = QQmlApplicationEngine()
    qml_dir = Path(__file__).parent / "qml"
    engine.addImportPath(str(qml_dir))
    engine.load(qml_dir / "Main.qml")

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

if __name__ == "__main__":
    main()