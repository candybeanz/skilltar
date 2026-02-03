import 'package:flutter/material.dart';
import '../models/workshop.dart';
import '../app_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _filters = const ['Near me', 'Beginner', 'Weekend', 'Under 10 credits'];
  int _activeFilter = 0;

  late final List<Workshop> mustTry;
  late final List<Workshop> trending;
  late final List<Workshop> quickPicks;

  @override
  void initState() {
    super.initState();

    // Dummy data for now (replace with Firestore later)
    mustTry = _sampleWorkshops().take(3).toList();
    trending = _sampleWorkshops().skip(1).take(3).toList();
    quickPicks = _sampleWorkshops();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Explore\nWorkshops',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                tooltip: 'Filters',
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _activeFilter;
                return ChoiceChip(
                  label: Text(_filters[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _activeFilter = i),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          _sectionHeader('Must-try workshops'),
          const SizedBox(height: 10),
          _horizontalCards(mustTry),

          const SizedBox(height: 18),

          _sectionHeader('Trending now'),
          const SizedBox(height: 10),
          _horizontalCards(trending),

          const SizedBox(height: 18),

          _sectionHeader('Quick picks'),
          const SizedBox(height: 10),
          ...quickPicks.map((w) => _quickPickTile(w)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ],
    );
  }

  Widget _horizontalCards(List<Workshop> list) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final w = list[i];
          return SizedBox(
            width: 220,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.workshopDetails,
                arguments: WorkshopDetailsArgs(w),
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                        ),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 28)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('${w.creditsRequired} credits • ⭐ ${w.rating.toStringAsFixed(1)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _quickPickTile(Workshop w) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.school)),
        title: Text(w.title),
        subtitle: Text('${w.category} • ${w.location}'),
        trailing: Text('${w.creditsRequired} cr'),
        onTap: () => Navigator.pushNamed(
          context,
          Routes.workshopDetails,
          arguments: WorkshopDetailsArgs(w),
        ),
      ),
    );
  }

  List<Workshop> _sampleWorkshops() {
    final now = DateTime.now();
    return [
      Workshop(
        id: 'arduino-starter',
        title: 'Arduino Starter Lab',
        category: 'Tech',
        creditsRequired: 10,
        rating: 4.8,
        location: 'SP Makerspace',
        description: 'Build your first Arduino circuit and learn sensors.',
        tags: const ['Beginner', 'Hands-on'],
        slots: [
          WorkshopSlot(start: now.add(const Duration(days: 2, hours: 14)), end: now.add(const Duration(days: 2, hours: 16)), capacity: 10, booked: 10),
          WorkshopSlot(start: now.add(const Duration(days: 5, hours: 10)), end: now.add(const Duration(days: 5, hours: 12)), capacity: 10, booked: 6),
          WorkshopSlot(start: now.add(const Duration(days: 8, hours: 19)), end: now.add(const Duration(days: 8, hours: 21)), capacity: 10, booked: 2),
        ],
      ),
      Workshop(
        id: 'lego-coding',
        title: 'LEGO Coding Sprint',
        category: 'Robotics',
        creditsRequired: 8,
        rating: 4.6,
        location: 'T11 Lab',
        description: 'Code simple robot behaviors with LEGO kits.',
        tags: const ['Beginner'],
        slots: [
          WorkshopSlot(start: now.add(const Duration(days: 3, hours: 11)), end: now.add(const Duration(days: 3, hours: 13)), capacity: 8, booked: 8),
          WorkshopSlot(start: now.add(const Duration(days: 7, hours: 15)), end: now.add(const Duration(days: 7, hours: 17)), capacity: 8, booked: 3),
        ],
      ),
      Workshop(
        id: 'digital-art',
        title: 'Digital Art Night',
        category: 'Arts',
        creditsRequired: 9,
        rating: 4.7,
        location: 'Online',
        description: 'Learn basic layers, brushes, and lighting.',
        tags: const ['Weekend'],
        slots: [
          WorkshopSlot(start: now.add(const Duration(days: 1, hours: 20)), end: now.add(const Duration(days: 1, hours: 22)), capacity: 20, booked: 20),
          WorkshopSlot(start: now.add(const Duration(days: 6, hours: 20)), end: now.add(const Duration(days: 6, hours: 22)), capacity: 20, booked: 9),
        ],
      ),
      Workshop(
        id: 'interview-prep',
        title: 'Interview Prep Bootcamp',
        category: 'Soft skills',
        creditsRequired: 12,
        rating: 4.9,
        location: 'Career Hub',
        description: 'Practice answers, confidence, and mini mock interviews.',
        tags: const ['Must-try'],
        slots: [
          WorkshopSlot(start: now.add(const Duration(days: 4, hours: 18)), end: now.add(const Duration(days: 4, hours: 20)), capacity: 12, booked: 11),
        ],
      ),
    ];
  }
}
