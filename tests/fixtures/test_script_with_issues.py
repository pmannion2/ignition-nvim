# Test script with deliberate issues for LSP diagnostics testing

# Issue 1: Hardcoded localhost
url = "http://localhost:8088/api/data"

# Issue 2: Print statement instead of system.perspective.print
print("Loading data...")

# Issue 3: HTTP call without error handling
response = system.net.httpGet(url)
data = system.util.jsonDecode(response)

# Issue 4: Mixed indentation (this line uses spaces, others use tabs)
    result = data['value']

# Issue 5: No error handling for component access
button = self.getSibling("Button1")
button.props.text = "Updated"

# Issue 6: More hardcoded localhost
backup_url = "http://127.0.0.1:8088/backup"

# This should trigger multiple diagnostics:
# - JYTHON_HARDCODED_LOCALHOST (2 occurrences)
# - JYTHON_PRINT_STATEMENT
# - JYTHON_HTTP_WITHOUT_EXCEPTION_HANDLING
# - JYTHON_MIXED_INDENTATION
# - JYTHON_RECOMMEND_ERROR_HANDLING
