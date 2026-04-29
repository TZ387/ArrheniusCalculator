import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


def main() -> None:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Arrhenius Calculator")
    app.setOrganizationName("ArrheniusCalc")

    engine = QQmlApplicationEngine()

    qml_dir = Path(__file__).parent / "qml"
    engine.addImportPath(str(qml_dir))          # points at qml/, which contains ArrheniusCalculator/
    engine.load(qml_dir / "Main.qml")
    
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()