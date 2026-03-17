---
description: QA test a feature using browser automation
argument-hint: [feature-description]
---

# QA Test

Verify completed work, test functionality, check edge cases, and validate user flows using browser automation.

## Usage

```bash
/ja:qa-test "Login form validation"
/ja:qa-test                           # Prompts for what to test
```

## Testing Approach

### 1. Understand the Feature

Before testing:
- Read the requirements/specification
- Understand expected behaviour
- Identify acceptance criteria
- List edge cases to verify

### 2. Prepare Test Environment

```bash
# Check if dev server is running
curl -s http://localhost:3000 > /dev/null && echo "Server running" || echo "Server not running"
```

### 3. Test Categories

#### Functional Testing
- Core feature works as expected
- All user flows complete successfully
- Form validation works correctly
- Error handling is appropriate

#### Edge Cases
- Empty states
- Maximum/minimum values
- Invalid input handling
- Concurrent operations
- Network failure scenarios

#### Accessibility Testing
- Keyboard navigation
- Screen reader compatibility
- Colour contrast
- Focus management

#### Responsive Testing
- Desktop viewport
- Tablet viewport
- Mobile viewport

### 4. Browser Automation

Use Chrome DevTools MCP tools for automated testing:

```javascript
// Navigate to page
mcp__chrome-devtools__navigate_page({ url: "http://localhost:3000/path" })

// Take snapshot to understand page structure
mcp__chrome-devtools__take_snapshot()

// Interact with elements
mcp__chrome-devtools__click({ selector: "button[type='submit']" })
mcp__chrome-devtools__fill({ selector: "input[name='email']", value: "test@example.com" })

// Take screenshot for evidence
mcp__chrome-devtools__take_screenshot()
```

### 5. Test Report Format

```markdown
## QA Test Report

### Feature Tested
[Feature name and description]

### Test Environment
- URL: [base URL]
- Browser: [browser used]
- Date: [test date]

### Test Results

#### Functional Tests
| Test Case | Status | Notes |
|-----------|--------|-------|
| User can submit form | PASS | |
| Validation shows errors | PASS | |
| Success message appears | FAIL | Message not displayed |

#### Edge Cases
| Test Case | Status | Notes |
|-----------|--------|-------|
| Empty form submission | PASS | Shows validation |
| Very long input | PASS | Truncated correctly |

#### Accessibility
| Check | Status | Notes |
|-------|--------|-------|
| Keyboard navigation | PASS | |
| Focus visible | PASS | |

### Issues Found
1. **[Issue Title]** - [Severity]
   - Steps to reproduce
   - Expected behaviour
   - Actual behaviour
   - Screenshot: [link]

### Recommendations
- [Recommendation 1]
- [Recommendation 2]

### Overall Status: PASS/FAIL
```

## Best Practices

- Test happy path first
- Then test error paths
- Document all findings with screenshots
- Prioritise issues by severity
- Verify fixes don't introduce regressions
- Test across different viewports
