#!/bin/bash

# Initialize an array to keep track of created files and directories
created_files=()
created_dirs=()

# Initialize error log file
error_log="error_log.txt"

# Function for rolling back changes in case of failure
rollback() {
    echo "Rolling back changes..." | tee -a "$error_log"
    for file in "${created_files[@]}"; do
        rm -f "$file"
    done
    for dir in "${created_dirs[@]}"; do
        rmdir "$dir" 2>/dev/null
    done
}

# Function to check if virtual environment is activated
is_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        return 0
    else
        return 1
    fi
}

echo "Initializing Git repository..."
git init >> "$error_log" 2>&1 && created_files+=(".git") || { echo "Git initialization failed" | tee -a "$error_log"; rollback; exit 1; }

echo "Creating Python virtual environment..."
python3 -m venv venv >> "$error_log" 2>&1 && created_dirs+=("venv") || { echo "Virtual environment creation failed" | tee -a "$error_log"; rollback; exit 1; }

echo "Activating the virtual environment..."
source venv/bin/activate
is_venv || { echo "Failed to activate virtual environment" | tee -a "$error_log"; rollback; exit 1; }

echo "Installing required packages..."
pip install pytest click gitpython >> "$error_log" 2>&1 || { echo "Package installation failed" | tee -a "$error_log"; rollback; exit 1; }

echo "Creating project directories..."
mkdir -p src tests logs backups >> "$error_log" 2>&1 && created_dirs+=("src" "tests" "logs" "backups") || { echo "Directory creation failed" | tee -a "$error_log"; rollback; exit 1; }

echo "Creating Python files..."
touch_files=("src/__init__.py" "src/project_analyzer.py" "src/dir_env_manager.py" "src/dep_pack_manager.py"
            "src/test_framework_manager.py" "src/logging_framework_manager.py" "src/version_control_manager.py"
            "src/backup_rollback_manager.py" "src/main.py")
for file in "${touch_files[@]}"; do
    touch "$file" >> "$error_log" 2>&1 && created_files+=("$file") || { echo "File creation failed" | tee -a "$error_log"; rollback; exit 1; }
done

echo "Creating Python test files..."
touch_test_files=("tests/__init__.py" "tests/test_project_analyzer.py" "tests/test_dir_env_manager.py" "tests/test_dep_pack_manager.py"
                 "tests/test_test_framework_manager.py" "tests/test_logging_framework_manager.py" "tests/test_version_control_manager.py"
                 "tests/test_backup_rollback_manager.py")
for file in "${touch_test_files[@]}"; do
    touch "$file" >> "$error_log" 2>&1 && created_files+=("$file") || { echo "Test file creation failed" | tee -a "$error_log"; rollback; exit 1; }
done

echo "Creating other important files..."
touch_other_files=("setup.py" "requirements.txt" "README.md")
for file in "${touch_other_files[@]}"; do
    touch "$file" >> "$error_log" 2>&1 && created_files+=("$file") || { echo "Failed to create miscellaneous files" | tee -a "$error_log"; rollback; exit 1; }
done

# Run initial tests to verify setup, allowing for no tests to be found
pytest tests/ --collect-only
pytest_status=$?

if [[ $pytest_status -ne 0 && $pytest_status -ne 5 ]]; then
    echo "Initial tests failed with unexpected error code: $pytest_status" | tee -a "$error_log"
    rollback
    exit 1
fi

# If everything succeeded, print a success message
echo "Project setup successfully completed!"
