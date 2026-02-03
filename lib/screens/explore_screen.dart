import 'package:flutter/material.dart';
import '../models/workshop.dart';
import '../state/skilltar_store.dart';
import 'workshop_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _store = SkilltarStore.I;

  final List<String> _filters = const [
    'Near me',
    'Beginner',
    'Weekend',
    'Under 10 credits',
  ];

  int _activeFilter = 0;

  // Disjoint sections (so not repeated)
  final Set<String> _mustTryIds = const {'arduino', 'digital_art', 'makeup'};
  final Set<String> _trendingIds = const {'lego', 'interview', 'photography'};
  final Set<String> _quickPickIds = const {'cooking', 'social', 'stock'};

  @override
  void initState() {
    super.initState();
    _store.initIfNeeded(_sampleWorkshops());
  }

  bool _passesFilter(Workshop w) {
    final selected = _filters[_activeFilter];
    switch (selected) {
      case 'Under 10 credits':
        return w.creditsRequired < 10;
      case 'Beginner':
        return w.tags.contains('Beginner');
      case 'Weekend':
        return w.tags.contains('Weekend');
      case 'Near me':
        return w.tags.contains('Near me');
      default:
        return true;
    }
  }

  List<Workshop> _section(List<Workshop> src, Set<String> ids) {
    return src.where((w) => ids.contains(w.id)).where(_passesFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + credits
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                        Text('Workshops', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _store.credits,
                    builder: (context, credits, _) {
                      return _CreditsPill(credits: credits);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_filters.length, (i) {
                  final selected = i == _activeFilter;
                  return ChoiceChip(
                    label: Text(_filters[i]),
                    selected: selected,
                    labelStyle: TextStyle(
                      color: selected ? const Color(0xFF3C2E62) : const Color(0xFF3C3C3C),
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: const Color(0xFFE3D9FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: selected ? const Color(0xFFE3D9FF) : const Color(0xFFD1CBE3),
                      ),
                    ),
                    onSelected: (_) => setState(() => _activeFilter = i),
                  );
                }),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: ValueListenableBuilder<List<Workshop>>(
                  valueListenable: _store.workshops,
                  builder: (context, all, _) {
                    final mustTry = _section(all, _mustTryIds);
                    final trending = _section(all, _trendingIds);
                    final quickPicks = _section(all, _quickPickIds);

                    final anyResults = mustTry.isNotEmpty || trending.isNotEmpty || quickPicks.isNotEmpty;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!anyResults)
                            Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Text(
                                'No workshops found for "${_filters[_activeFilter]}".',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),

                          if (mustTry.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _sectionTitle('Must-try workshops'),
                            const SizedBox(height: 10),
                            _horizontalCards(mustTry),
                          ],

                          if (trending.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _sectionTitle('Trending now'),
                            const SizedBox(height: 10),
                            _horizontalCards(trending),
                          ],

                          if (quickPicks.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _sectionTitle('Quick picks'),
                            const SizedBox(height: 10),
                            _quickPickList(quickPicks),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900));
  }

  // Give list more height (prevents tiny overflow on some screens)
  Widget _horizontalCards(List<Workshop> items) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final w = items[index];
          return _WorkshopCard(
            workshop: w,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkshopDetailsScreen(workshopId: w.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _quickPickList(List<Workshop> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final aTime = a.nextAvailableSlot?.start ?? DateTime(3000);
      final bTime = b.nextAvailableSlot?.start ?? DateTime(3000);
      return aTime.compareTo(bTime);
    });

    return Column(
      children: sorted.map((w) {
        final slot = w.nextAvailableSlot;
        final subtitle = slot == null
            ? 'No slots available'
            : '${_fmtDate(slot.start)} • ${_fmtTime(slot.start)} • ${slot.remaining} left';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkshopDetailsScreen(workshopId: w.id),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x1A000000),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE7E1F5)),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      w.imageAsset,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFEAE2FF),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${w.creditsRequired} credits • ☆ ${w.rating.toStringAsFixed(1)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fmtDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final wd = weekdays[d.weekday - 1];
    final mo = months[d.month - 1];
    final day = d.day.toString().padLeft(2, '0');
    return '$wd, $day $mo';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hh = (h % 12 == 0) ? 12 : (h % 12);
    return '$hh:$m $suffix';
  }

  List<Workshop> _sampleWorkshops() {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);

    // Always returns a FUTURE date for the given weekday (Mon=1 ... Sun=7)
    DateTime nextWkday(int weekday, int hour, int minute, {int weeksAhead = 0}) {
      int daysAhead = (weekday - base.weekday) % 7;
      if (daysAhead == 0) daysAhead = 7; // force "next" occurrence
      daysAhead += weeksAhead * 7;
      final date = base.add(Duration(days: daysAhead));
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    // Helpers
    DateTime sat(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.saturday, hour, minute, weeksAhead: weeksAhead);
    DateTime sun(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.sunday, hour, minute, weeksAhead: weeksAhead);

    DateTime tue(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.tuesday, hour, minute, weeksAhead: weeksAhead);
    DateTime wed(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.wednesday, hour, minute, weeksAhead: weeksAhead);
    DateTime thu(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.thursday, hour, minute, weeksAhead: weeksAhead);
    DateTime mon(int hour, int minute, {int weeksAhead = 0}) =>
        nextWkday(DateTime.monday, hour, minute, weeksAhead: weeksAhead);

    return [
      // Must-try
      Workshop(
        id: 'arduino',
        title: 'Arduino Starter Lab',
        category: 'Tech',
        creditsRequired: 10,
        rating: 4.8,
        location: 'SP Makerspace',
        description: 'Build your first Arduino circuit and learn sensors + basic coding.',
        tags: const ['Beginner', 'Near me'],
        imageAsset: 'assets/images/arduino.png',
        slots: [
          WorkshopSlot(start: tue(10, 0), durationMinutes: 90, capacity: 18, booked: 14),
          WorkshopSlot(start: thu(14, 0), durationMinutes: 90, capacity: 18, booked: 18),
          WorkshopSlot(start: tue(11, 0, weeksAhead: 1), durationMinutes: 90, capacity: 18, booked: 10),
        ],
      ),

      // ✅ Weekend-tagged -> weekend slots
      Workshop(
        id: 'digital_art',
        title: 'Digital Art Night',
        category: 'Art',
        creditsRequired: 9,
        rating: 4.7,
        location: 'Design Studio',
        description: 'A chill guided session for beginner digital illustration + brushes.',
        tags: const ['Beginner', 'Weekend'],
        imageAsset: 'assets/images/digital_art.png',
        slots: [
          WorkshopSlot(start: sat(19, 0), durationMinutes: 120, capacity: 22, booked: 20),
          WorkshopSlot(start: sat(19, 0, weeksAhead: 1), durationMinutes: 120, capacity: 22, booked: 12),
        ],
      ),

      // Weekend-tagged -> weekend slots
      Workshop(
        id: 'makeup',
        title: 'Makeup Masterclass',
        category: 'Lifestyle',
        creditsRequired: 11,
        rating: 4.9,
        location: 'Studio 3',
        description: 'Learn base + eye + lip techniques with a simple step-by-step routine.',
        tags: const ['Weekend'],
        imageAsset: 'assets/images/makeup.png',
        slots: [
          WorkshopSlot(start: sun(16, 0), durationMinutes: 75, capacity: 16, booked: 16),
          WorkshopSlot(start: sun(16, 0, weeksAhead: 1), durationMinutes: 75, capacity: 16, booked: 9),
        ],
      ),

      // Trending
      // ✅ Weekend-tagged -> weekend slots
      Workshop(
        id: 'lego',
        title: 'LEGO Coding Sprint',
        category: 'Tech',
        creditsRequired: 8,
        rating: 4.6,
        location: 'Robotics Lab',
        description: 'Fast-paced LEGO challenge: build + program mini tasks in teams.',
        tags: const ['Beginner', 'Near me', 'Weekend'],
        imageAsset: 'assets/images/lego.png',
        slots: [
          WorkshopSlot(start: sat(15, 0), durationMinutes: 90, capacity: 24, booked: 21),
          WorkshopSlot(start: sat(15, 0, weeksAhead: 1), durationMinutes: 90, capacity: 24, booked: 7),
        ],
      ),

      Workshop(
        id: 'interview',
        title: 'Interview Prep Bootcamp',
        category: 'Career',
        creditsRequired: 12,
        rating: 4.9,
        location: 'LT Lobby',
        description: 'Practice common interview Qs + resume tips + mock sessions.',
        tags: const ['Near me'],
        imageAsset: 'assets/images/interview.png',
        slots: [
          WorkshopSlot(start: wed(13, 30), durationMinutes: 90, capacity: 20, booked: 15),
          WorkshopSlot(start: wed(13, 30, weeksAhead: 1), durationMinutes: 90, capacity: 20, booked: 20),
          WorkshopSlot(start: wed(13, 30, weeksAhead: 2), durationMinutes: 90, capacity: 20, booked: 6),
        ],
      ),

      // ✅ Weekend-tagged -> weekend slots
      Workshop(
        id: 'photography',
        title: 'Photography Walk & Edit',
        category: 'Creative',
        creditsRequired: 9,
        rating: 4.5,
        location: 'Campus Outdoors',
        description: 'Shoot around campus then do a simple edit workflow (mobile-friendly).',
        tags: const ['Weekend'],
        imageAsset: 'assets/images/photogrphy.png',
        slots: [
          WorkshopSlot(start: sun(9, 0), durationMinutes: 120, capacity: 18, booked: 17),
          WorkshopSlot(start: sun(9, 0, weeksAhead: 1), durationMinutes: 120, capacity: 18, booked: 8),
        ],
      ),

      // Quick picks
      // ✅ Weekend-tagged -> weekend slots
      Workshop(
        id: 'cooking',
        title: 'Cooking Basics: 1-Pan Meals',
        category: 'Food',
        creditsRequired: 7,
        rating: 4.4,
        location: 'Demo Kitchen',
        description: 'Easy recipes + timing tricks. Great if you’re busy but want good food.',
        tags: const ['Beginner', 'Weekend'],
        imageAsset: 'assets/images/cooking.png',
        slots: [
          WorkshopSlot(start: sat(18, 0), durationMinutes: 90, capacity: 14, booked: 10),
          WorkshopSlot(start: sat(18, 0, weeksAhead: 1), durationMinutes: 90, capacity: 14, booked: 14),
        ],
      ),

      Workshop(
        id: 'social',
        title: 'Social Content Studio',
        category: 'Media',
        creditsRequired: 6,
        rating: 4.3,
        location: 'Media Room',
        description: 'Plan + shoot + edit short content. Learn basic hooks and pacing.',
        tags: const ['Beginner', 'Near me'],
        imageAsset: 'assets/images/scoial.png',
        slots: [
          WorkshopSlot(start: mon(17, 0), durationMinutes: 75, capacity: 20, booked: 12),
          WorkshopSlot(start: mon(17, 0, weeksAhead: 1), durationMinutes: 75, capacity: 20, booked: 19),
        ],
      ),

      Workshop(
        id: 'stock',
        title: 'Stock Investing 101',
        category: 'Finance',
        creditsRequired: 9,
        rating: 4.2,
        location: 'Seminar Room B',
        description: 'Understand basics: risk, diversification, and how to read simple charts.',
        tags: const ['Beginner'],
        imageAsset: 'assets/images/stock.png',
        slots: [
          WorkshopSlot(start: wed(12, 0), durationMinutes: 90, capacity: 30, booked: 29),
          WorkshopSlot(start: wed(12, 0, weeksAhead: 1), durationMinutes: 90, capacity: 30, booked: 14),
        ],
      ),
    ];
  }
}

class _CreditsPill extends StatelessWidget {
  final int credits;
  const _CreditsPill({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E1F5)),
        boxShadow: const [
          BoxShadow(blurRadius: 16, offset: Offset(0, 8), color: Color(0x12000000)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFF6B5EA8)),
          const SizedBox(width: 6),
          Text('$credits credits', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final VoidCallback onTap;

  const _WorkshopCard({
    required this.workshop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7E1F5)),
          boxShadow: const [
            BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 118,
                width: double.infinity,
                child: Image.asset(
                  workshop.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEAE2FF),
                    child: const Center(child: Icon(Icons.image, size: 34)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${workshop.creditsRequired} credits • ☆ ${workshop.rating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF3C3C3C)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    workshop.hasAvailability ? 'Slots available' : 'Full',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: workshop.hasAvailability ? const Color(0xFF2E7D32) : const Color(0xFFB00020),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
