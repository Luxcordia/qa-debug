# Remediation Playbook Extended Reference

Extended patterns for distributed systems, database-specific scenarios, frontend resilience, and async/queue failure modes.

---

## Circuit Breaker Implementation Pattern

```python
# Pseudocode — adapt to your language/framework
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.state = "closed"       # closed | open | half-open
        self.failures = 0
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.last_failure_time = None

    def call(self, fn):
        if self.state == "open":
            if time.now() - self.last_failure_time > self.recovery_timeout:
                self.state = "half-open"
            else:
                raise CircuitOpenError("Circuit is open — fast-fail")

        try:
            result = fn()
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise

    def _on_success(self):
        self.failures = 0
        self.state = "closed"

    def _on_failure(self):
        self.failures += 1
        self.last_failure_time = time.now()
        if self.failures >= self.failure_threshold:
            self.state = "open"
```

**Testing the circuit breaker (propose to user — do not auto-run):**
1. Mock the dependency to fail N times → assert circuit opens
2. Mock the dependency to recover after timeout → assert circuit half-opens and closes on success
3. Verify that requests during open state fail fast (< 5ms) without touching the dependency

---

## Retry with Backoff — Full Implementation Pattern

```python
import random
import time

def retry_with_backoff(fn, max_attempts=4, base_delay=1.0, max_delay=30.0):
    """
    Exponential backoff with full jitter.
    Wait formula: random(0, min(base * 2^attempt, max_delay))
    Full jitter prevents synchronized retries (thundering herd).
    """
    for attempt in range(max_attempts):
        try:
            return fn()
        except RetryableError as e:
            if attempt == max_attempts - 1:
                raise  # Final attempt — propagate

            cap = min(base_delay * (2 ** attempt), max_delay)
            wait = random.uniform(0, cap)  # Full jitter
            time.sleep(wait)

    # Should not reach here
    raise RuntimeError("Retry loop exited without return or raise")
```

**What to make retryable vs. non-retryable:**

| Error | Retryable? | Reason |
|-------|-----------|--------|
| `HTTP 429 Too Many Requests` | ✅ Yes (respect `Retry-After` header) | Transient rate limit |
| `HTTP 503 Service Unavailable` | ✅ Yes | Transient unavailability |
| `HTTP 500 Internal Server Error` | ⚠️ Maybe | Only if operation is idempotent |
| `HTTP 400 Bad Request` | ❌ No | Client error — retrying won't fix it |
| `HTTP 401 / 403` | ❌ No | Auth error — retrying won't fix it |
| Network timeout (read) | ✅ Yes | With idempotency key if write operation |
| `HTTP 409 Conflict` | ❌ No | State conflict — retry requires re-reading state first |

---

## Idempotency Key Pattern

Ensures write operations are safe to retry without duplicate side effects:

```python
# Pattern: generate key at call site, pass through to provider
import uuid

def place_order(cart_id, idempotency_key=None):
    if idempotency_key is None:
        idempotency_key = str(uuid.uuid4())

    # Provider checks: have I seen this key?
    # If yes → return previous result
    # If no → process and store key before responding
    return payment_service.charge(
        cart_id=cart_id,
        idempotency_key=idempotency_key
    )
```

**Idempotency key testing (propose to user):**
1. Send request with key K → expect success response R
2. Send identical request with same key K → expect **identical** response R (not a new charge)
3. Send request with different key K2 → expect new operation processed

---

## Database-Specific Patterns

### Reversible Migration Template (propose this structure in action items)

```sql
-- up.sql
ALTER TABLE orders ADD COLUMN discount_cents INTEGER DEFAULT 0 NOT NULL;

-- down.sql
ALTER TABLE orders DROP COLUMN discount_cents;
```

**Two-phase column removal (never remove in one deploy):**
- **Phase 1 deploy**: Stop writing to the column; application reads with fallback
- **Wait**: Let one full deploy cycle pass; verify no writes in logs
- **Phase 2 deploy**: Drop the column in down.sql

### N+1 Query Pattern (common performance root cause)

```python
# BAD — N+1 (1 query for orders + N queries for items)
orders = Order.objects.all()
for order in orders:
    print(order.items.all())  # New query per order

# GOOD — Eager load
orders = Order.objects.prefetch_related('items').all()
```

Diagnostic step to propose: `EXPLAIN ANALYZE` on the slow query — look for Sequential Scan on large tables or nested loop joins.

---

## Async / Queue Failure Modes

| Failure Mode | Pattern | Test to Propose |
|-------------|---------|----------------|
| Message processed twice | Idempotency key in handler | Send same message ID twice → assert side effect happens once |
| Message never acknowledged | Dead-letter queue (DLQ) | Mock handler crash → verify message lands in DLQ after N retries |
| Poison message blocks queue | DLQ + max-retry count | Send malformed message → verify it moves to DLQ and does not block |
| Consumer crashes mid-processing | Ack only after successful processing | Kill consumer mid-job → verify message is re-delivered |
| Queue grows unboundedly | Back-pressure + consumer scaling alert | Simulate slow consumer → alert fires before queue depth exceeds SLA |

---

## Frontend Resilience Patterns

### Optimistic UI with Rollback
```javascript
// Show success immediately; revert if API fails
function updateItem(id, value) {
    // 1. Update UI optimistically
    setItems(prev => prev.map(i => i.id === id ? { ...i, value } : i));

    // 2. Call API
    api.update(id, value).catch(err => {
        // 3. Revert on failure — must keep previous state
        setItems(previousItems);
        showError("Update failed — changes reverted");
    });
}
```

### Stale-While-Revalidate
- Show cached data immediately (stale = better than blank)
- Fetch fresh data in background
- Update UI when fresh data arrives
- If fresh fetch fails, keep showing stale data with a staleness indicator

---

## Rollback Decision Tree

```
Is the fix reversible?
├── No  → Escalate before proceeding; design a forward-fix instead
└── Yes → Does it touch production data?
           ├── Yes → Test down() migration in staging first; have DBA on standby
           └── No  → Proceed with standard git revert + re-deploy
                      └── Does it require a dependency change?
                           ├── Yes → Pin previous version in lock file first
                           └── No  → Feature flag off; redeploy; monitor for 30 minutes
```
