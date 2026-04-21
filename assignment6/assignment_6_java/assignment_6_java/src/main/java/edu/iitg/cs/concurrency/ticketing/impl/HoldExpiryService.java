package edu.iitg.cs.concurrency.ticketing.impl;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;

final class HoldExpiryService {
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(Runtime.getRuntime().availableProcessors());
    private final ConcurrentHashMap<Long, ScheduledFuture<?>> tasks = new ConcurrentHashMap<>();

    void scheduleExpiry(long holdId, long ttlMs, Runnable expireAction) {
        // TODO: schedule and keep cancellable handle
        ScheduledFuture<?> future = scheduler.schedule(() -> {
            try {
                expireAction.run();
            } finally {
                tasks.remove(holdId);
            }
        }, ttlMs, TimeUnit.MILLISECONDS);

        tasks.put(holdId, future);
    }

    void cancelExpiry(long holdId) {
        // TODO: cancel scheduled task if present

        ScheduledFuture<?> future = tasks.remove(holdId);

        if (future != null) {
            future.cancel(false);
        }
    }

    void shutdown() {
        scheduler.shutdown();
    }
}
