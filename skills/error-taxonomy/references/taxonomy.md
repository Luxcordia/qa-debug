# Error Taxonomy Extended Reference

Extended classification examples, regex patterns for common error formats, and fingerprinting guidance by language.

---

## Stack Trace Parsing by Language

### Python

```
Traceback (most recent call last):
  File "/app/services/cart.py", line 47, in calculate_total
    total = sum(item['price'] for item in cart_items)
  File "/app/services/cart.py", line 47, in <genexpr>
    total = sum(item['price'] for item in cart_items)
KeyError: 'price'
```

**Parsing rules:**
- First non-library frame: the last `File "/app/..."` entry (ignore `site-packages` frames)
- Error type: `KeyError` → map to **Runtime** → "Missing key assumption" root cause
- Normalize for fingerprint: strip line numbers, keep `KeyError: 'price'` as the error signature

**Common Python error → root cause mappings:**

| Exception | Most Likely Root Cause |
|-----------|----------------------|
| `KeyError` | Dict access without `.get()` or key existence check |
| `AttributeError: 'NoneType' object has no attribute X` | Unguarded None — function returned None silently |
| `TypeError: unsupported operand type(s)` | Type coercion assumption (e.g., string + int) |
| `RecursionError` | Missing base case in recursive function |
| `MemoryError` | Unbounded list/string growth — fuzz or large-payload scenario |
| `UnicodeDecodeError` | Input not validated as UTF-8 at boundary |

---

### Node.js / JavaScript

```
TypeError: Cannot read properties of undefined (reading 'price')
    at CartTotal.render (CartTotal.jsx:47:18)
    at processChild (react-dom/cjs/react-dom.development.js:3990:14)
    ...
```

**Parsing rules:**
- First non-library frame: first `at` entry whose path does NOT contain `node_modules`
- Error type: `TypeError: Cannot read properties of undefined` → **Runtime** → "Unguarded nullable/undefined"
- Normalize: strip line:column numbers, strip `react-dom/cjs/...` frames entirely

**Common Node.js error → root cause mappings:**

| Error Pattern | Most Likely Root Cause |
|---------------|----------------------|
| `Cannot read properties of undefined (reading 'X')` | Optional chaining (`?.`) missing, or function returns `undefined` silently |
| `ECONNREFUSED` | Service not running, wrong port, firewall rule |
| `ETIMEDOUT` | No timeout set on outbound request |
| `UnhandledPromiseRejectionWarning` | Missing `.catch()` or `try/catch` in async function |
| `RangeError: Maximum call stack size exceeded` | Recursive function without base case |
| `SyntaxError: Unexpected token` in JSON | Parsing an HTML error page as JSON (check Content-Type before parsing) |

---

### Java

```
java.lang.NullPointerException: Cannot invoke "String.length()" because "str" is null
    at com.example.cart.CartService.calculateTotal(CartService.java:84)
    at com.example.cart.CartController.checkout(CartController.java:52)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    ...
```

**Parsing rules:**
- First non-`sun.reflect` / `java.lang` / `org.springframework` frame = application code
- Strip line numbers and method handles for fingerprint; keep class + method + exception type
- `NullPointerException` in Java 17+ includes the null variable name — use it for root cause

---

### Go

```
goroutine 1 [running]:
panic: runtime error: index out of range [5] with length 3

goroutine 1 [running]:
main.processItems(...)
    /app/services/cart.go:42 +0x6c
```

**Parsing rules:**
- The `panic:` line is the error type — extract before normalizing
- Strip goroutine IDs and hex offsets (`+0x6c`) for fingerprint
- `index out of range` → **Runtime** → "Array access without bounds check"

---

## Fingerprint Normalization Regexes

Use these patterns to strip dynamic values before hashing:

```python
import re

def normalize_for_fingerprint(trace: str) -> str:
    # Strip line numbers
    trace = re.sub(r'\.py:\d+', '.py:<line>', trace)
    trace = re.sub(r'\.js:\d+:\d+', '.js:<line>', trace)
    trace = re.sub(r'\.java:\d+', '.java:<line>', trace)
    trace = re.sub(r'\.go:\d+', '.go:<line>', trace)

    # Strip memory addresses
    trace = re.sub(r'0x[0-9a-fA-F]+', '<addr>', trace)

    # Strip UUIDs and IDs in error messages
    trace = re.sub(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', '<uuid>', trace)
    trace = re.sub(r'\b\d{4,}\b', '<id>', trace)  # Numeric IDs 4+ digits

    # Strip timestamps
    trace = re.sub(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z?', '<timestamp>', trace)

    return trace.strip()
```

---

## Recurrence vs. Regression Disambiguation

| Scenario | Status | Evidence |
|----------|--------|---------|
| First time this fingerprint has been seen | `new` | No match in error archive |
| Fingerprint matches an existing open ticket | `known` | Match in archive with `status: known` |
| Fingerprint matches a ticket previously marked `resolved` | `regression` | Match in archive with `status: resolved`, newer `last_seen` |
| Fingerprint matches a ticket in the current sprint's changes | `regression` | Match + recent git commit on the affected component |

**Regression confirmation steps (propose, do not auto-run):**
1. Look up the fingerprint in the error archive — does it exist with `status: resolved`?
2. Check when it was resolved and compare to the timeline of recent deploys
3. Propose `git bisect` between the resolved date and now to identify the reintroducing commit
