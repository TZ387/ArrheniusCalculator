# ArrheniusCalculator

A simple QML GUI application that calculates the Arrhenius integral for various cases (tabular data, functional data, etc.).

The program is still in development, so not all listed features are working.

## Option 1: Install from PyPi

### Option a: Using uv

```bash
uvx arrheniuscalculator
```

or inside a project:

```bash
uv add arrheniuscalculator
uv run arrheniuscalculator
```

### Option b: Using pip

```bash
pip install arrheniuscalculator
arrheniuscalculator
```

## Option 2: Installation from source

### Option a: Using uv

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator
uv sync
uv run arrheniuscalculator
```

### Option b: Using pip

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator

python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

pip install -e .
python -m arrheniuscalculator.main
```

