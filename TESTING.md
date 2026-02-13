# Testing the Ansible Execution Environment

This document describes how to test the Ansible Execution Environment (EE) to ensure it works correctly.

## Automated Testing (GitHub Actions)

The repository includes a GitHub Actions workflow that automatically tests the EE on every push and pull request.

**Location:** `.github/workflows/test-ee.yml`

### Test Coverage

The automated test suite includes:

1. **Ansible Version Check** - Verifies Ansible is installed and accessible
2. **Collections Inventory** - Lists installed Ansible collections
3. **Plugin Documentation** - Verifies Ansible plugins are available
4. **Comprehensive Test Suite** - Runs the test-ee.sh script for detailed validation
5. **Python Environment** - Checks for required Python packages (Jinja2, PyYAML, etc.)
6. **Playbook Parsing** - Validates that playbook syntax checking works
7. **Simple Playbook Execution** - Runs a test playbook to verify end-to-end functionality

## Manual Testing

### Test the image locally

```bash
# Build the image locally
docker build -t test-ee:latest context/

# Run the comprehensive test suite
docker run --rm -v $(pwd)/test-ee.sh:/test-ee.sh:ro test-ee:latest bash /test-ee.sh

# Or test individual components
docker run --rm test-ee:latest ansible --version
docker run --rm test-ee:latest ansible-galaxy collection list
docker run --rm test-ee:latest python3 -c "import ansible; print(ansible.__version__)"
```

### Run a playbook with the EE

```bash
# Create a test playbook
cat > test-playbook.yml << 'EOF'
---
- name: Test Playbook
  hosts: localhost
  gather_facts: yes
  tasks:
    - name: Display system info
      debug:
        msg: "Running on {{ ansible_os_family }}"
EOF

# Run it in the container
docker run --rm -v $(pwd)/test-playbook.yml:/test-playbook.yml:ro test-ee:latest \
  ansible-playbook /test-playbook.yml
```

### Using Docker Compose for testing

```yaml
version: '3.8'
services:
  ee:
    image: test-ee:latest
    volumes:
      - ./playbooks:/playbooks:ro
    working_dir: /playbooks
    command: ansible-playbook site.yml
```

Then run:
```bash
docker-compose up
```

## Test Script Details

The `test-ee.sh` script performs the following validations:

### Test 1: Ansible Installation
- Checks if `ansible` command is available
- Displays Ansible version

### Test 2: Collection Management
- Verifies `ansible-galaxy` works correctly
- Lists installed collections
- Ensures collection management is functional

### Test 3: Python Environment
- Validates Python 3 is available
- Checks for required packages: `ansible`, `jinja2`, `yaml`, `json`, `configparser`
- Reports version information for each package

### Test 4: Playbook Syntax Validation
- Creates a test playbook
- Runs syntax check using `ansible-playbook --syntax-check`
- Ensures playbook parsing works correctly

### Test 5: Test Playbook Execution
- Executes the test playbook against localhost
- Validates end-to-end playbook execution
- Confirms `debug` module functionality

### Test 6: Module Verification
- Attempts to verify common Ansible modules are accessible
- Provides warnings if verification fails (non-blocking)

## Expected Output

A successful test run should produce output similar to:

```
=========================================
Ansible Execution Environment Test Suite
=========================================

[TEST 1] Checking Ansible installation...
✓ Ansible is installed
ansible 2.9.27

[TEST 2] Checking ansible-galaxy...
✓ ansible-galaxy works
   Collections installed:
   ...

[TEST 3] Checking Python environment...
✓ Python 3.9.25
✓ ansible: 2.9.27
✓ jinja2: 3.0.0
✓ yaml: 5.4.1
✓ json: unknown
✓ configparser: unknown

[TEST 4] Testing playbook parsing...
✓ Playbook syntax is valid

[TEST 5] Running test playbook...
✓ Playbook executed successfully

[TEST 6] Checking for common Ansible modules...
✓ Common modules found

=========================================
✓ All tests passed!
=========================================
```

## Troubleshooting

### Test Fails: "Ansible not found"

**Cause:** The image doesn't have Ansible installed correctly.

**Solution:** Verify that:
- The `requirements.txt` includes Ansible packages
- The pip installation step completed successfully
- Check the Docker build logs for errors

### Test Fails: "ansible-galaxy collection list" doesn't work

**Cause:** Collections aren't available or properly installed.

**Solution:**
- Verify `requirements.yml` is properly formatted
- Check that collection installation completed in the build
- Try listing collections manually: `ansible-galaxy collection list`

### Playbook execution fails

**Cause:** Missing Python dependencies or module compatibility issues.

**Solution:**
- Check Python version compatibility with your playbooks
- Verify all required Python packages are installed
- Test with the `debug` module first (simplest test)

## Adding Custom Tests

You can extend the test suite by:

1. **Adding tests to `test-ee.sh`**:
   ```bash
   # Test 7: Your custom test
   echo ""
   echo "[TEST 7] Your test description..."
   # Your test commands here
   ```

2. **Adding steps to the GitHub Actions workflow**:
   ```yaml
   - name: My custom test
     run: |
       docker run --rm test-ee:latest your-test-command
   ```

3. **Creating test playbooks**:
   - Place playbooks in a `tests/playbooks/` directory
   - Reference them in the workflow or test script
   - Include assertions for validation

## CI/CD Integration

The test workflow runs automatically on:
- Every push to `main` or `master` branches
- Every pull request to `main` or `master` branches

You can manually trigger the workflow from the GitHub Actions tab.

## Success Criteria

The Ansible Execution Environment is considered working when:

✅ All tests pass (no `✗` marks)  
✅ Ansible and required modules are installed  
✅ Collections are properly installed  
✅ At least one test playbook executes successfully  
✅ Python environment has all required packages  

## Resources

- [Ansible Execution Environments Documentation](https://ansible.readthedocs.io/projects/docker-container/en/)
- [ansible-builder Project](https://github.com/ansible/ansible-builder)
- [Ansible Documentation](https://docs.ansible.com/)
