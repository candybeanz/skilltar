import 'package:flutter/foundation.dart';
import '../models/workshop.dart';

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

  /// Bookings made by user (demo) - key = "workshopId|slotStartIso"
  final ValueNotifier<Set<String>> bookings = ValueNotifier<Set<String>>({});

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
    return bookings.value.contains(_slotKey(workshopId, start));
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

    // Save booking key so it can't be booked again
    final nextBookings = {...bookings.value};
    nextBookings.add(_slotKey(workshopId, start));
    bookings.value = nextBookings;

    return BookResult.success;
  }
}
