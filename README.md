# ArrheniusCalculator

The intention of this project is to develop a simple QML GUI application that will calculate the Arrhenius integral for various cases (tabular data, functional data, etc.).

## Installation

### Option 1: Using uv

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator
uv sync
uv run main.py
```

### Option 2: Using pip

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator

python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

pip install PySide6
python main.py
```

### Notes

- No PyPI package yet — you need to install it directly from source