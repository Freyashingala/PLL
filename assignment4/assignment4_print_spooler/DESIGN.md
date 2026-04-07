# Assignment 4

* **Name:** Freya Mitulbhai Shingala
* **Roll no.:** 230101094

## Overview

Implemented a thread-safe print spooler that supports:
* Multiple concurrent producers submitting jobs
* A bounded blocking queue to prevent unbounded memory usage
* A dispatcher thread that assigns jobs to a fixed-size worker pool
* Job cancellation (both queued and in-progress)
* Clean shutdown without deadlocks or lost jobs

---

## 1. BoundedJobQueue Design

The queue is implemented using:
* `synchronized` blocks
* `while(condition) wait()` for blocking behavior
* `notifyAll()` after enqueue/dequeue/remove

### Properties:
* **putBlocking()** blocks when queue is full
* **takeBlocking()** blocks when queue is empty
* **putWithTimeout()** waits up to a deadline
* **removeIfPresent()** supports cancellation

### Correctness:
* Uses `while` instead of `if` to handle spurious wakeups
* Ensures producers and consumers coordinate without deadlock
* `notifyAll()` guarantees no thread starvation

---

## 2. JobRegistry Design

The registry maintains a HashMap:
```
jobId → JobRecord

HashMap<Long, JobRecord>
```

### Synchronization:

* All methods are declared `synchronized`
* Ensures atomic access and linearizable operations

### State Machine:

* QUEUED → PRINTING → DONE
* QUEUED → CANCELLED
* PRINTING → CANCELLED

### Key Methods:

* create(jobId, job)
     * Inserts a new job with initial state ` QUEUED `
* markPrinting(jobId)
     * Transitions job to ` PRINTING `
     * Prevents printing if job was already cancelled
* markDone(jobId)
     * Marks job as ` DONE ` only if currently ` PRINTING `
* markCancelled(jobId)
     * Sets status to ` CANCELLED `
     * Sets ` cancelRequested = true ` (volatile for visibility)
* status(jobId)
     * Returns current job status

### Correctness: 

* Synchronization ensures consistent state transitions
* Volatile cancellation flag ensures visibility across threads
* Prevents invalid transitions such as ` DONE → CANCELLED `
---

## 3. Dispatcher + Worker Design

### Dispatcher Thread

* Continuously removes jobs from the queue and submits them to the worker pool.
<!-- * queue.takeBlocking() → pool.submit(worker) -->

### Worker Execution

Each job is processed by a `PrintWorker`:

* Calls `markPrinting()` before execution
* Simulates printing page-by-page
* Checks ` cancelRequested ` flag during execution
* Calls ` markDone() ` after completion

### Metrics Handling

* After worker execution, dispatcher reads final job status
* Updates:
```
     JobStatus st = registry.status(jobId); 
     if (st == DONE) completed++ 
     else if (st == CANCELLED) cancelled++
```
---

## 4. Cancellation Design

Two cases:

### Queued Job

* Removed using `removeIfPresent()`
* Marked `CANCELLED` in registry

### In-Progress Job

* `cancelRequested = true` (volatile)
* Worker detects it and transitions to CANCELLED

Cancellation is visible across threads immediately

---

## 5. Shutdown (close()) Design
Shutdown is implemented in close() as follows:

1. Set `closed = true`
2. Interrupt dispatcher thread
3. Wait for dispatcher to terminate (`join()`)
4. Shutdown worker pool
5. Wait briefly using `awaitTermination()`
6. Force shutdown if necessary (`shutdownNow()`)

Dispatcher stops fetching new jobs after interruption.

Worker threads may still complete already submitted tasks.

Pool shutdown ensures no new tasks are accepted.

---

## 6. Concurrency Control

The system uses:

* `synchronized` for queue and registry
* `wait()` / `notifyAll()` for coordination
* `volatile` for cancellation visibility
* `AtomicLong` for metrics counters
* Ordering:
  ```
  Dispatcher → Worker → Registry → Metrics
  ```

---
## 7. Deadlock Avoidance

* Each class uses its own monitor
* No nested locking between classes
* `notifyAll()` prevents missed wakeups

---

## 8. Correctness Guarantees

The system ensures:

* No job is processed more than once
* No job is lost
* Every submitted job eventually reaches:

  `
  DONE or CANCELLED
  `
* Queue never exceeds capacity
* System shuts down cleanly

---

## Conclusion

The design implements a bounded producer-consumer system with:

* Thread-safe queue
* Consistent job state tracking
* Parallel execution using worker threads
* Support for cancellation and shutdown

The system follows standard concurrency practices using only core Java primitives.