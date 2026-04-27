package edu.iitg.cs.concurrency.ticketing.impl;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

final class HoldExpiryService {
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final ConcurrentHashMap<Long, ScheduledFuture<?>> tasks = new ConcurrentHashMap<>();    // keeps track of user's holdId to their specific ScheduledFuture

    void scheduleExpiry(long holdId, long ttlMs, Runnable expireAction) {
        // TODO: schedule and keep cancellable handle
        ScheduledFuture<?> future = scheduler.schedule(() -> {
            try {   // makes sure the task cleans up after itself as soon as it finishes (prevent outOfMemoryError)
                expireAction.run();
            } finally {
                tasks.remove(holdId);
            }
        }, ttlMs, TimeUnit.MILLISECONDS);

        tasks.put(holdId, future);  // storing so that it can be retrieved later
    }

    void cancelExpiry(long holdId) {
        // TODO: cancel scheduled task if present

        ScheduledFuture<?> future = tasks.remove(holdId);

        if (future != null) {
            future.cancel(false);   // cancel task if hasnt started yet, but dont interrupt if running
        }
    }

    void shutdown() {
        scheduler.shutdown();
    }
}
