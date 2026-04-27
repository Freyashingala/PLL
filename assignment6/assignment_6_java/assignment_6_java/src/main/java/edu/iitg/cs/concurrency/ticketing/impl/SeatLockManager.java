package edu.iitg.cs.concurrency.ticketing.impl;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

final class SeatLockManager {
    void lockAll(List<Seat> seats) throws InterruptedException {
        // TODO(STUDENT): implement deadlock-free locking.
        // Current naive strategy is NOT safe under concurrency.

        // creating a duplicate so that original order is intact
        List<Seat> sortedSeats = new ArrayList<>(seats);
        sortedSeats.sort(Comparator.comparingInt(s -> s.seatId));   // sort seats to eliminate circular wait (enforcing lock ordering globally)
        for (Seat s : sortedSeats) {
            s.lock.lockInterruptibly(); // listens to interruption signals instead of waiting forever
        }
    }

    void unlockAll(List<Seat> seats) {

        // similar to lockAll
        List<Seat> sortedSeats = new ArrayList<>(seats);
        sortedSeats.sort(Comparator.comparingInt(s -> s.seatId));

        for (int i = sortedSeats.size()-1; i >= 0; i--) {
            Seat s = sortedSeats.get(i);
            if (s.lock.isHeldByCurrentThread()) s.lock.unlock();
        }
    }
}
