class WorkshopSlot {
  final DateTime start;
  final int durationMinutes;
  final int capacity;
  final int booked;

  const WorkshopSlot({
    required this.start,
    required this.durationMinutes,
    required this.capacity,
    required this.booked,
  });

  int get remaining => capacity - booked;
  bool get isAvailable => remaining > 0;

  WorkshopSlot copyWith({
    DateTime? start,
    int? durationMinutes,
    int? capacity,
    int? booked,
  }) {
    return WorkshopSlot(
      start: start ?? this.start,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      capacity: capacity ?? this.capacity,
      booked: booked ?? this.booked,
    );
  }
}

class Workshop {
  final String id;
  final String title;
  final String category;
  final int creditsRequired;
  final double rating;
  final String location;
  final String description;
  final List<String> tags;
  final String imageAsset;
  final List<WorkshopSlot> slots;

  const Workshop({
    required this.id,
    required this.title,
    required this.category,
    required this.creditsRequired,
    required this.rating,
    required this.location,
    required this.description,
    required this.tags,
    required this.imageAsset,
    required this.slots,
  });

  bool get hasAvailability => slots.any((s) => s.isAvailable);

  WorkshopSlot? get nextAvailableSlot {
    final available = slots.where((s) => s.isAvailable).toList();
    if (available.isEmpty) return null;
    available.sort((a, b) => a.start.compareTo(b.start));
    return available.first;
  }

  Workshop copyWith({
    String? id,
    String? title,
    String? category,
    int? creditsRequired,
    double? rating,
    String? location,
    String? description,
    List<String>? tags,
    String? imageAsset,
    List<WorkshopSlot>? slots,
  }) {
    return Workshop(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      creditsRequired: creditsRequired ?? this.creditsRequired,
      rating: rating ?? this.rating,
      location: location ?? this.location,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      imageAsset: imageAsset ?? this.imageAsset,
      slots: slots ?? this.slots,
    );
  }
}
