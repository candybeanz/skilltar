import 'package:flutter/foundation.dart';
import '../models/workshop.dart';
import '../models/booking.dart';

enum BookResult { success, full, insufficientCredits, notFound, alreadyBooked }

class SkilltarStore {
  SkilltarStore._();

  static final SkilltarStore I = SkilltarStore._();

  /// User starts with 50 credits after sign up (demo).
  final ValueNotifier<int> credits = ValueNotifier<int>(50);

  /// Source of truth for workshops + slot availability.
  final ValueNotifier<List<Workshop>> workshops = ValueNotifier<List<Workshop>>([]);

  /// Slot reminder flags (demo) - key = "workshopId|slotStartIso"
  final ValueNotifier<Set<String>> reminders = ValueNotifier<Set<String>>({});

  /// Bookings made by user - now storing full Booking objects
  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>([]);

  void initIfNeeded(List<Workshop> initial) {
    if (workshops.value.isEmpty) {
      workshops.value = initial;
    }
  }

  Workshop? getWorkshop(String id) {
    for (final w in workshops.value) {
      if (w.id == id) return w;
    }
    return null;
  }

  String _slotKey(String workshopId, DateTime start) =>
      '$workshopId|${start.toIso8601String()}';

  // ---------- reminders ----------
  bool isReminderOn(String workshopId, DateTime start) {
    return reminders.value.contains(_slotKey(workshopId, start));
  }

  void toggleReminder(String workshopId, DateTime start) {
    final key = _slotKey(workshopId, start);
    final next = {...reminders.value};
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    reminders.value = next;
  }

  // ---------- bookings ----------
  bool isBooked(String workshopId, DateTime start) {
    return bookings.value.any(
      (b) => b.workshopId == workshopId && 
             b.slotStart == start && 
             (b.status == BookingStatus.confirmed || b.status == BookingStatus.waitlist)
    );
  }

  /// Get bookings filtered by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return bookings.value.where((b) => b.status == status).toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart)); // Sort by date
  }

  /// Get all upcoming bookings (confirmed + waitlist)
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return bookings.value
        .where((b) => 
          (b.status == BookingStatus.confirmed || b.status == BookingStatus.waitlist) &&
          b.slotStart.isAfter(now))
        .toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart));
  }

  BookResult bookSlot({
    required String workshopId,
    required DateTime start,
  }) {
    // Prevent booking same slot multiple times
    if (isBooked(workshopId, start)) return BookResult.alreadyBooked;

    final list = workshops.value;
    final wi = list.indexWhere((w) => w.id == workshopId);
    if (wi == -1) return BookResult.notFound;

    final w = list[wi];
    final si = w.slots.indexWhere((s) => s.start == start);
    if (si == -1) return BookResult.notFound;

    final slot = w.slots[si];
    if (!slot.isAvailable) return BookResult.full;

    if (credits.value < w.creditsRequired) {
      return BookResult.insufficientCredits;
    }

    // Update slot booked count (+1)
    final updatedSlot = slot.copyWith(booked: slot.booked + 1);
    final newSlots = [...w.slots];
    newSlots[si] = updatedSlot;

    final updatedWorkshop = w.copyWith(slots: newSlots);
    final newWorkshops = [...list];
    newWorkshops[wi] = updatedWorkshop;

    workshops.value = newWorkshops;
    credits.value = credits.value - w.creditsRequired;

    // Create new booking object
    final newBooking = Booking(
      id: '${workshopId}_${start.millisecondsSinceEpoch}',
      workshopId: workshopId,
      workshopTitle: w.title,
      workshopImageAsset: w.imageAsset,
      slotStart: start,
      slotDurationMinutes: slot.durationMinutes,
      location: w.location,
      creditsSpent: w.creditsRequired,
      status: BookingStatus.confirmed,
      bookedAt: DateTime.now(),
    );

    bookings.value = [...bookings.value, newBooking];

    return BookResult.success;
  }

  /// Cancel a booking
  /// Returns credits refunded (0 if late cancellation)
  int cancelBooking(String bookingId) {
    final list = bookings.value;
    final index = list.indexWhere((b) => b.id == bookingId);
    
    if (index == -1) return 0;
    
    final booking = list[index];
    
    // Can only cancel confirmed or waitlist bookings
    if (!booking.isCancellable) return 0;

    // Update booking status to cancelled
    final updatedBooking = booking.copyWith(status: BookingStatus.cancelled);
    final newBookings = [...list];
    newBookings[index] = updatedBooking;
    bookings.value = newBookings;

    // Refund credits if ≥3 days before workshop
    int refund = 0;
    if (booking.canRefundCredits()) {
      refund = booking.creditsSpent;
      credits.value = credits.value + refund;
    }

    // Decrease the workshop slot's booked count (free up the spot)
    final workshop = getWorkshop(booking.workshopId);
    if (workshop != null) {
      final slotIndex = workshop.slots.indexWhere((s) => s.start == booking.slotStart);
      if (slotIndex != -1) {
        final slot = workshop.slots[slotIndex];
        final updatedSlot = slot.copyWith(booked: (slot.booked - 1).clamp(0, slot.capacity));
        final newSlots = [...workshop.slots];
        newSlots[slotIndex] = updatedSlot;
        
        final updatedWorkshop = workshop.copyWith(slots: newSlots);
        final workshopList = workshops.value;
        final wi = workshopList.indexWhere((w) => w.id == booking.workshopId);
        if (wi != -1) {
          final newWorkshops = [...workshopList];
          newWorkshops[wi] = updatedWorkshop;
          workshops.value = newWorkshops;
        }
      }
    }

    return refund;
  }
}