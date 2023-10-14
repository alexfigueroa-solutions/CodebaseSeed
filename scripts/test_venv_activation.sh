#!/bin/bash

# Debug: Output the current state of the VIRTUAL_ENV variable
echo "Initial VIRTUAL_ENV: $VIRTUAL_ENV"

# Clear any existing virtual environment to simulate a fresh start
deactivate 2>/dev/null || true

# Debug: Output after deactivation
echo "After deactivation: $VIRTUAL_ENV"

# Your setup steps go here
echo "Creating virtual environment..."
python3 -m venv test_venv

echo "Activating virtual environment..."
source test_venv/bin/activate

# Debug: Output after activation
echo "After activation: $VIRTUAL_ENV"

# Check for virtual environment activation
if [[ -z "$VIRTUAL_ENV" ]]; then
  echo "Test Failed: Virtual environment was not activated."
  exit 1
else
  echo "Test Passed: Virtual environment activated."
  exit 0
fi
