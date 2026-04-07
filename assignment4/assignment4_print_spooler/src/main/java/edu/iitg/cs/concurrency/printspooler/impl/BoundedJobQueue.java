package edu.iitg.cs.concurrency.printspooler.impl;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * TODO(STUDENT): Implement a correct bounded blocking queue using:
 * - synchronized
 * - while(condition) wait()
 * - notifyAll() after enqueue/dequeue/remove
 */
final class BoundedJobQueue {
    private final int capacity;
    private final Deque<Long> q = new ArrayDeque<>();
    private int maxDepth = 0;

    BoundedJobQueue(int capacity) {
        if (capacity <= 0) throw new IllegalArgumentException("capacity must be > 0");
        this.capacity = capacity;
    }

    int maxDepthObserved() {
        synchronized (this) { return maxDepth; }
    }

    void putBlocking(long jobId) throws InterruptedException {
        // TODO(STUDENT)
        synchronized (this) {
            while (q.size() == capacity) {
                wait();
            }
            q.addLast(jobId);   // adding jobId to queue
            maxDepth = Math.max(maxDepth, q.size());    // track maximum queue depth reached for metrics
            notifyAll();
        }
    }

    boolean putWithTimeout(long jobId, long timeoutMs) throws InterruptedException {
        synchronized (this) {
            // TODO(STUDENT)
            long deadline = System.currentTimeMillis() + timeoutMs; // calculating absolute deadline to handle multiple wakeups

            while (q.size() == capacity) {
                long remaining = deadline - System.currentTimeMillis();
                if (remaining <= 0) return false;   // if timeout expired, stop waiting and fail insertion
                wait(remaining);    // wait remaining time
            }

            q.addLast(jobId);
            maxDepth = Math.max(maxDepth, q.size());
            notifyAll();
            return true;
        }
    }

    long takeBlocking() throws InterruptedException {
        synchronized (this) {
            // TODO(STUDENT)
            while (q.isEmpty()) {
                wait(); // blocking consumer when queue is empty
            }
            long id = q.removeFirst();
            notifyAll();    // space available in queue
            return id;
        }
    }

    boolean removeIfPresent(long jobId) {
        synchronized (this) {
            boolean removed = q.remove(jobId);
            if (removed) notifyAll();
            return removed;
        }
    }
}
