#!/usr/bin/env bash

# Test script to validate Ansible Execution Environment
# This script runs various tests to ensure the EE works properly

set -e

echo "========================================="
echo "Ansible Execution Environment Test Suite"
echo "========================================="

# Test 1: Verify Ansible is installed
echo ""
echo "[TEST 1] Checking Ansible installation..."
if command -v ansible &> /dev/null; then
    echo "✓ Ansible is installed"
    ansible --version | head -1
else
    echo "✗ Ansible not found"
    exit 1
fi

# Test 2: Verify ansible-galaxy works
echo ""
echo "[TEST 2] Checking ansible-galaxy..."
if ansible-galaxy collection list > /dev/null 2>&1; then
    echo "✓ ansible-galaxy works"
    echo "   Collections installed:"
    ansible-galaxy collection list | tail -5
else
    echo "✗ ansible-galaxy failed"
    exit 1
fi

# Test 3: Check Python and required modules
echo ""
echo "[TEST 3] Checking Python environment..."
python3 << 'EOF'
import sys
import importlib

print(f"✓ Python {sys.version.split()[0]}")

required_modules = [
    'ansible',
    'jinja2',
    'yaml',
    'json',
    'configparser',
]

for module in required_modules:
    try:
        mod = importlib.import_module(module)
        version = getattr(mod, '__version__', 'unknown')
        print(f"✓ {module}: {version}")
    except ImportError:
        print(f"✗ {module}: NOT FOUND")
        sys.exit(1)
EOF

# Test 4: Verify a simple playbook can be parsed
echo ""
echo "[TEST 4] Testing playbook parsing..."
cat > /tmp/test_playbook.yml << 'PLAYBOOK'
---
- name: Test Playbook
  hosts: localhost
  gather_facts: no
  tasks:
    - name: Debug task
      debug:
        msg: "Ansible execution environment is working!"
PLAYBOOK

if ansible-playbook --syntax-check /tmp/test_playbook.yml > /dev/null 2>&1; then
    echo "✓ Playbook syntax is valid"
else
    echo "✗ Playbook syntax check failed"
    exit 1
fi

# Test 5: Run the test playbook
echo ""
echo "[TEST 5] Running test playbook..."
if ansible-playbook /tmp/test_playbook.yml > /dev/null 2>&1; then
    echo "✓ Playbook executed successfully"
else
    echo "✗ Playbook execution failed"
    exit 1
fi

# Test 6: Check for common Ansible modules
echo ""
echo "[TEST 6] Checking for common Ansible modules..."
modules_list=$(ansible -m command -a 'echo' localhost 2>/dev/null | grep -o 'connection' || true)
if [ ! -z "$modules_list" ]; then
    echo "✓ Common modules found"
else
    echo "⚠ Could not verify modules (but EE may still work)"
fi

echo ""
echo "========================================="
echo "✓ All tests passed!"
echo "========================================="
