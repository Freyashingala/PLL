# Assignment 6: Concurrent Ticketing System Architecture

* **Name:** Freya Mitulbhai Shingala
* **Roll no.:** 230101094

## Overview

This document details the concurrency strategies, synchronization mechanisms, and task management patterns implemented in the ticketing system to ensure thread safety, high throughput, and data consistency under heavy concurrent load.

## 1. Synchronization Strategy

The system avoids `synchronized` blocks, which would bottleneck throughput, in favor of locking and concurrent data structures.

### Thread-Safe State Management (`ConcurrentHashMap`)
* The `holds` tracking map is implemented as a `ConcurrentHashMap`. 
* A standard `HashMap` is not thread-safe and can become corrupted or cause infinite loops during concurrent writes. `ConcurrentHashMap` safely handles thousands of concurrent read/write operations without locking the entire map.

### Atomic Gatekeeping (Fetch-and-Delete)
* In state-mutating methods (`confirm`, `cancel`, `expireHold`), the hold is retrieved using `holds.remove(holdId)` rather than `holds.get(holdId)`.
* This acts as an atomic gatekeeper. If a background expiry timer and a user confirmation attempt to process the same ticket at the exact same time, `.remove()` ensures only one thread receives the `Hold` object. The other receives `null` and safely aborts, preventing double-processing and corruption.

### Race Condition Prevention (Dirty Read + Re-verify)
* Inside `holdSeats`, threads find `FREE` seats using a lock-free read. Once candidate seats are locked, the thread re-verifies their state (`if (s.state != SeatState.FREE)`) before proceeding. 
* This prevents Time-Of-Check to Time-Of-Use race conditions. If another thread acquires the lock and books the seat in the fraction of a second between the read and the lock, the re-verification catches the change, safely aborts the operation, and forces the thread to retry.

## 2. Deadlock Prevention Strategy

Locking multiple independent resources (seats) concurrently introduces the risk of Circular Wait deadlocks (e.g., Thread A holds Seat 1 waiting for Seat 2; Thread B holds Seat 2 waiting for Seat 1).

### Global Lock Ordering
* Inside `SeatLockManager.lockAll()`, the requested list of seats is copied and **sorted by `seatId`** before any locks are requested.
* By enforcing a strict mathematical acquisition order across all threads, Circular Wait is mathematically impossible. All threads will always compete for the lowest-numbered seat first.

### LIFO Lock Release
* In `unlockAll()`, locks are released in the exact reverse order of acquisition (iterating backward through the sorted list).
* Releasing locks in Last-In-First-Out (LIFO) order prevents subtle timing bugs and race conditions during the unlock phase.

### Interruptible Locking
* Seat locks are acquired using `s.lock.lockInterruptibly()` rather than standard `lock()`.
* If the system requires a graceful shutdown, or if a thread gets stuck, `lockInterruptibly()` allows the thread to be safely cancelled via an `InterruptedException`, whereas standard locks would wait blindly forever.

## 3. Expiry and Task Cancellation Handling

Background tasks (timers) are managed to ensure they do not leak memory, waste CPU cycles, or interfere with active user operations.

### Task Tracking
* The `HoldExpiryService` utilizes a `ConcurrentHashMap<Long, ScheduledFuture<?>>` to link every `holdId` to its specific background timer task.

### Safe Cancellation (`future.cancel(false)`)
* When a ticket is explicitly confirmed or cancelled by the user, the system retrieves the `ScheduledFuture` and calls `cancel(false)`.
* Passing `false` instructs Java to cancel the task if it hasn't started, but to **not interrupt it** if it is already executing. If the task is already actively acquiring seat locks, forcefully interrupting the thread could corrupt seat states or cause `IllegalMonitorStateException` errors.

### Memory Leak Prevention (Self-Cleaning Tasks)
* When a scheduled task is created, the executable logic is wrapped in a `try-finally` block that calls `tasks.remove(holdId)` upon completion.
* If a timer finishes naturally, its `ScheduledFuture` reference would otherwise remain in the tracking map forever. This self-cleaning mechanism prevents the map from infinitely growing and eventually causing an `OutOfMemoryError`.