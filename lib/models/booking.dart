enum BookingStatus {
  confirmed,
  waitlist,
  completed,
  cancelled,
}

class Booking {
  final String id; // unique booking ID
  final String workshopId;
  final String workshopTitle;
  final String workshopImageAsset;
  final DateTime slotStart;
  final int slotDurationMinutes;
  final String location;
  final int creditsSpent;
  final BookingStatus status;
  final DateTime bookedAt; // when the booking was made

  const Booking({
    required this.id,
    required this.workshopId,
    required this.workshopTitle,
    required this.workshopImageAsset,
    required this.slotStart,
    required this.slotDurationMinutes,
    required this.location,
    required this.creditsSpent,
    required this.status,
    required this.bookedAt,
  });

  /// Check if this booking can be cancelled with credit refund
  /// Cancel ≥ 3 days before → refund credits
  /// Late cancel (<3 days) → credits are forfeited
  bool canRefundCredits() {
    final now = DateTime.now();
    final daysUntilWorkshop = slotStart.difference(now).inDays;
    return daysUntilWorkshop >= 3;
  }

  /// Check if booking is cancellable (only confirmed/waitlist can be cancelled)
  bool get isCancellable {
    return status == BookingStatus.confirmed || status == BookingStatus.waitlist;
  }

  Booking copyWith({
    String? id,
    String? workshopId,
    String? workshopTitle,
    String? workshopImageAsset,
    DateTime? slotStart,
    int? slotDurationMinutes,
    String? location,
    int? creditsSpent,
    BookingStatus? status,
    DateTime? bookedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      workshopTitle: workshopTitle ?? this.workshopTitle,
      workshopImageAsset: workshopImageAsset ?? this.workshopImageAsset,
      slotStart: slotStart ?? this.slotStart,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      location: location ?? this.location,
      creditsSpent: creditsSpent ?? this.creditsSpent,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}