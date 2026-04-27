package edu.iitg.cs.concurrency.ticketing.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

import edu.iitg.cs.concurrency.ticketing.api.Hold;
import edu.iitg.cs.concurrency.ticketing.api.Receipt;
import edu.iitg.cs.concurrency.ticketing.api.SeatState;
import edu.iitg.cs.concurrency.ticketing.api.TicketMetrics;
import edu.iitg.cs.concurrency.ticketing.api.TicketService;

public final class TicketServiceImpl implements TicketService {
    public static final long HOLD_TTL_MS = 1500;

    private final Seat[] seats;
    private final SeatLockManager lockMgr = new SeatLockManager();
    private final HoldExpiryService expiry = new HoldExpiryService();

    // added concurrent to hashmap (to make it thread-safe)
    private final Map<Long, Hold> holds = new ConcurrentHashMap<>(); // TODO: protect with synchronized/locks
    private final AtomicLong holdIdGen = new AtomicLong(1);
    private final AtomicLong receiptIdGen = new AtomicLong(1);

    private final CopyOnWriteArrayList<String> auditLog = new CopyOnWriteArrayList<>();

    private final AtomicLong successful = new AtomicLong();
    private final AtomicLong expired = new AtomicLong();
    private final AtomicLong rejected = new AtomicLong();

    private volatile boolean closed = false;

    public TicketServiceImpl(int seatCount) {
        if (seatCount <= 0) throw new IllegalArgumentException("seatCount must be > 0");
        this.seats = new Seat[seatCount];
        for (int i = 0; i < seatCount; i++) seats[i] = new Seat(i);
    }

    @Override
    public Hold holdSeats(String userId, int count) throws InterruptedException {
        if (closed) throw new IllegalStateException("closed");
        if (count <= 0) throw new IllegalArgumentException("count must be > 0");

        // wrapped in while loop, prevents race conditions (double booking)
        while(true) {
            List<Seat> chosen = new ArrayList<>();
            for (Seat s : seats) {
                if (chosen.size() == count) break;
                if (s.state == SeatState.FREE) chosen.add(s);
            }
            if (chosen.size() < count) {
                rejected.incrementAndGet();
                return null;
            }

            lockMgr.lockAll(chosen);
            try {
                // TODO: re-check they are FREE after locking, then mark HELD, record hold atomically
                // re-verify state inside the lock
                boolean allFree = true;
                for (Seat s : chosen) {
                    if (s.state != SeatState.FREE) {
                        allFree = false;
                        break;
                    }
                }
                
                // if another thread stole the seats, unlock and retry the while loop
                if (!allFree) {
                    continue; 
                }

                long hid = holdIdGen.getAndIncrement();
                long now = System.currentTimeMillis();
                for (Seat s : chosen) {
                    s.state = SeatState.HELD;
                    s.holdId = hid;
                }
                Hold h = new Hold(hid, userId, chosen.stream().map(seat -> seat.seatId).toList(), now);
                holds.put(hid, h);
                auditLog.add("HOLD " + hid + " user=" + userId);

                expiry.scheduleExpiry(hid, HOLD_TTL_MS, () -> expireHold(hid));
                return h;
            } finally {
                lockMgr.unlockAll(chosen);
            }
        }
    }

    private void expireHold(long holdId) {
        // TODO: atomically release seats if still HELD for this holdId

        Hold h = holds.remove(holdId);  // prevents expriy timer if user already confirmed or cancelled ticket
        if (h == null) return; 

        List<Seat> ss = new ArrayList<>();  // temporary list to get seat objects from seat number
        for (int sid : h.seatIds()) ss.add(seats[sid]);
        try {
            lockMgr.lockAll(ss);
            try {   // this try is for if we lock it we always unlock it
                boolean expiredAny = false;
                for (Seat s : ss) {
                    // verify the seat wasn't somehow re-assigned 
                    if (s.state == SeatState.HELD && s.holdId == holdId) {
                        s.state = SeatState.FREE;
                        s.holdId = -1;
                        expiredAny = true;
                    }
                }
                if (expiredAny) {
                    expired.incrementAndGet();
                    auditLog.add("EXPIRE " + holdId);
                }
            } finally {
                lockMgr.unlockAll(ss);
            }
        } catch (InterruptedException e) {  // handles thread interruptions during shutdown
            Thread.currentThread().interrupt();
        }
    }

    @Override
    public Receipt confirm(long holdId) throws InterruptedException {
        if (closed) throw new IllegalStateException("closed");
        Hold h = holds.remove(holdId);  // made it remove instead of get as remove is atomic
        if (h == null) {
            rejected.incrementAndGet();
            return null;
        }

        expiry.cancelExpiry(holdId);

        List<Seat> ss = new ArrayList<>();
        for (int sid : h.seatIds()) ss.add(seats[sid]);

        lockMgr.lockAll(ss);
        try {
            // TODO: validate still held by this holdId, then book
            for (Seat s : ss) {
                if (s.state != SeatState.HELD || s.holdId != holdId) {
                    rejected.incrementAndGet();
                    return null;
                }
            }
            for (Seat s : ss) s.state = SeatState.BOOKED;
            // expiry.cancelExpiry(holdId);
            // holds.remove(holdId);
            successful.incrementAndGet();
            auditLog.add("CONFIRM " + holdId);
            return new Receipt(receiptIdGen.getAndIncrement(), h.userId(), h.seatIds(), System.currentTimeMillis());
        } finally {
            lockMgr.unlockAll(ss);
        }
    }

    @Override
    public boolean cancel(long holdId) {
        Hold h = holds.remove(holdId);
        if (h == null) return false;

        // TODO: lock seats and release atomically
        // similar to confirm
        expiry.cancelExpiry(holdId);

        List<Seat> ss = new ArrayList<>();
        for (int sid : h.seatIds()) ss.add(seats[sid]);
        try {
            lockMgr.lockAll(ss);
            try {
                for (Seat s : ss) {
                    if (s.state == SeatState.HELD && s.holdId == holdId) {
                        s.state = SeatState.FREE;
                        s.holdId = -1;
                    }
                }
                auditLog.add("CANCEL " + holdId);
                return true;
            } finally {
                lockMgr.unlockAll(ss);
            }
        } catch (InterruptedException e) {  // handles thread interruptions during shutdown
            Thread.currentThread().interrupt();
            return false;
        }
    }

    @Override
    public SeatState seatState(int seatId) {
        return seats[seatId].state;
    }

    @Override
    public TicketMetrics metrics() {
        return new TicketMetrics(successful.get(), expired.get(), rejected.get());
    }

    @Override
    public void close() throws Exception {
        closed = true;
        expiry.shutdown();
    }
}
