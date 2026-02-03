class Workshop {
  final String id;
  final String title;
  final String category;
  final int creditsRequired;
  final double rating;
  final String location;
  final String description;
  final List<String> tags;
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
    required this.slots,
  });
}

class WorkshopSlot {
  final DateTime start;
  final DateTime end;
  final int capacity;
  final int booked;

  const WorkshopSlot({
    required this.start,
    required this.end,
    required this.capacity,
    required this.booked,
  });

  bool get isFull => booked >= capacity;
}
