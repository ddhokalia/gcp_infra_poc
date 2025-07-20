#!/usr/bin/env bash
set -e

# Build util wheel
cd apis/v2/genai_utils
python setup.py bdist_wheel
mv dist/*.whl ../dist/
cd ../../..

# Install util and test CF
pip install --find-links apis/v2/dist genai_utils==0.1.0
cd apis/v2/cf-demo
pip install -r requirements.txt
pytest -q
