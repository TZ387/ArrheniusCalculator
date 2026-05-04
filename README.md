# ArrheniusCalculator

A simple QML-based application for calculating the Arrhenius integral across different scenarios, including discrete data and analytical functions.

Using the application is straightforward: click the Launch button and choose the type of calculation you want. Then enter the required parameters and press Calculate. You can hover over the question mark icons for additional guidance where needed.

![ArrheniusCalculator Screenshot](https://github.com/TZ387/ArrheniusCalculator/raw/main/Demonstration.png)

## Installation

### Option 1: Install from PyPi

#### Option a: Using uv

```bash
uvx arrheniuscalculator
```

or inside a project:

```bash
uv add arrheniuscalculator
uv run arrheniuscalculator
```

#### Option b: Using pip

```bash
pip install arrheniuscalculator
arrheniuscalculator
```

Or if Python is not included to path:

```bash
arrheniuscalculator.main
```

### Option 2: Installation from source

#### a: Using uv

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator
uv sync
uv run arrheniuscalculator
```

#### b: Using pip

```bash
git clone https://github.com/TZ387/ArrheniusCalculator.git
cd ArrheniusCalculator

python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

pip install -e .
python -m arrheniuscalculator.main
```
