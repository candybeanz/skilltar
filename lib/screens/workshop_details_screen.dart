import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/workshop.dart';
import '../state/skilltar_store.dart';

class WorkshopPlaceInfo {
  final String address;
  final double lat;
  final double lng;
  final List<String> learn;
  final List<String> make;

  const WorkshopPlaceInfo({
    required this.address,
    required this.lat,
    required this.lng,
    required this.learn,
    required this.make,
  });
}

WorkshopPlaceInfo _placeForWorkshop(String workshopId) {
  switch (workshopId) {
    case 'digital_art':
      return const WorkshopPlaceInfo(
        address: 'Skilltar Design Studio, Dover Hub (Level 3)',
        lat: 1.3099,
        lng: 103.7773,
        learn: [
          'Brush control + layer basics (clean lineart)',
          'Colouring + shading with simple lighting',
          'Export your final artwork for socials',
        ],
        make: [
          '1 finished illustration (PNG)',
          'A mini brush + layer workflow cheat sheet',
        ],
      );

    case 'arduino':
      return const WorkshopPlaceInfo(
        address: 'Skilltar Makerspace Lab, T11 Block (Workshop Room 02)',
        lat: 1.3097,
        lng: 103.7778,
        learn: [
          'Build a basic circuit safely (LED + resistor)',
          'Read a sensor input + write simple logic',
          'Upload code + debug common errors',
        ],
        make: [
          'A working mini sensor demo circuit',
          'Starter Arduino template code',
        ],
      );

    case 'lego':
      return const WorkshopPlaceInfo(
        address: 'Skilltar Robotics Corner, Innovation Wing (Studio 1)',
        lat: 1.3102,
        lng: 103.7769,
        learn: [
          'Use loops + conditions for robot behaviour',
          'Control motors + react to simple inputs',
          'Team-based coding sprint workflow',
        ],
        make: [
          'A mini “robot mission” build',
          'A simple logic flow plan',
        ],
      );

    case 'interview':
      return const WorkshopPlaceInfo(
        address: 'Skilltar Career Lounge, Dover Hub (Meeting Pods)',
        lat: 1.3096,
        lng: 103.7768,
        learn: [
          'Answer confidently using STAR structure',
          'SQL basics: SELECT / WHERE / JOIN overview',
          'How to explain projects clearly',
        ],
        make: [
          'A personal answer-bank template',
          'A checklist for interview day',
        ],
      );

    default:
      return const WorkshopPlaceInfo(
        address: 'Skilltar Studio, Dover Area',
        lat: 1.3099,
        lng: 103.7773,
        learn: [
          'Step-by-step fundamentals for beginners',
          'Hands-on practice + guidance',
        ],
        make: [
          'A completed mini project',
        ],
      );
  }
}

/// Primary static map (often works well on web)
String _wikimediaStaticMapUrl(double lat, double lng) {
  const zoom = 16;
  const w = 760;
  const h = 320;
  return 'https://maps.wikimedia.org/img/osm-intl,$zoom,'
      '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)},${w}x$h.png';
}

/// Fallback provider (use if wikimedia fails)
String _osmStaticMapFallbackUrl(double lat, double lng) {
  final center = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
  final uri = Uri.https(
    'staticmap.openstreetmap.fr',
    '/staticmap.php',
    {
      'center': center,
      'zoom': '16',
      'size': '760x320',
      'maptype': 'mapnik',
      'markers': center,
    },
  );
  return uri.toString();
}

Widget _bulletList(List<String> items) {
  return Column(
    children: items
        .map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: const TextStyle(fontSize: 14, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

Future<void> _openMap(BuildContext context, WorkshopPlaceInfo place) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}');

  final mode = kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;
  final ok = await launchUrl(uri, mode: mode);

  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open map')),
    );
  }
}

class WorkshopDetailsScreen extends StatelessWidget {
  final String workshopId;
  WorkshopDetailsScreen({super.key, required this.workshopId});

  final _store = SkilltarStore.I;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Workshop>>(
      valueListenable: _store.workshops,
      builder: (context, workshops, _) {
        final workshop = _store.getWorkshop(workshopId);

        if (workshop == null) {
          return const Scaffold(
            body: Center(child: Text('Workshop not found')),
          );
        }

        final place = _placeForWorkshop(workshop.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F1FF),
          appBar: AppBar(
            title: Text(workshop.title),
            backgroundColor: const Color(0xFFF7F1FF),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _store.credits,
                    builder: (context, credits, _) {
                      return _CreditsMiniPill(credits: credits);
                    },
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.asset(
                      workshop.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEAE2FF),
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  '${workshop.creditsRequired} credits • ☆ ${workshop.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),

                Text(
                  workshop.location,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5A5A5A)),
                ),
                const SizedBox(height: 12),

                const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  workshop.description,
                  style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 18),
                Text(
                  "What you'll learn",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _bulletList(place.learn),

                const SizedBox(height: 18),
                Text(
                  "You'll make / take home",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _bulletList(place.make),

                const SizedBox(height: 18),
                Text(
                  "Location",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.address,
                        style: const TextStyle(fontSize: 14, height: 1.25),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ Clickable map (opens Google Maps)
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openMap(context, place),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 140, // smaller so it doesn't dominate the page
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Try Wikimedia first, fallback if it errors
                          Image.network(
                            _wikimediaStaticMapUrl(place.lat, place.lng),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) {
                              return Image.network(
                                _osmStaticMapFallbackUrl(place.lat, place.lng),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.map, size: 40),
                                ),
                              );
                            },
                          ),

                          // Small "Open map" hint pill
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE7E1F5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.open_in_new, size: 16),
                                  SizedBox(width: 6),
                                  Text('Open map', style: TextStyle(fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Available slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),

                ...workshop.slots.map((s) => _SlotTile(workshop: workshop, slot: s)),


              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  final Workshop workshop;
  final WorkshopSlot slot;

  _SlotTile({required this.workshop, required this.slot});

  final _store = SkilltarStore.I;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store.bookings, _store.reminders]),
      builder: (context, _) {
        final available = slot.remaining;
        final bookedByUser = _store.isBooked(workshop.id, slot.start);
        final reminderOn = _store.isReminderOn(workshop.id, slot.start);

        // Decide tap behaviour
        VoidCallback? onTap;
        if (bookedByUser) {
          onTap = null; // disable completely
        } else if (slot.isAvailable) {
          onTap = () async {
            await _confirmAndBookDialog(context, _store, workshop, slot);
          };
        } else {
          // full slot -> allow reminder toggle
          onTap = () {
            _store.toggleReminder(workshop.id, slot.start);
            final msg = reminderOn
                ? 'Reminder removed.'
                : 'Reminder set 🔔 (demo) — we’ll notify you if a spot opens.';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          };
        }

        final bgColor = bookedByUser ? const Color(0xFFF1F1F5) : Colors.white;
        final borderColor = bookedByUser ? const Color(0xFFD8D5E6) : const Color(0xFFE7E1F5);
        final textColor = bookedByUser ? const Color(0xFF7A7A7A) : Colors.black;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_fmtDate(slot.start)} • ${_fmtTime(slot.start)} • ${slot.durationMinutes} min',
                    style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
                  ),
                ),

                // Right-side status
                if (bookedByUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 18, color: Color(0xFF6B5EA8)),
                      SizedBox(width: 6),
                      Text(
                        'Booked',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6B5EA8)),
                      ),
                    ],
                  )
                else if (available > 0)
                  Text(
                    '$available left',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Full',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB00020)),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        reminderOn
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: const Color(0xFF6B5EA8),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
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
}


class _CreditsMiniPill extends StatelessWidget {
  final int credits;
  const _CreditsMiniPill({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E1F5)),
      ),
      child: Text('$credits credits', style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
Future<void> _confirmAndBookDialog(
  BuildContext context,
  SkilltarStore store,
  Workshop workshop,
  WorkshopSlot slot,
) async {
  final creditsNow = store.credits.value;
  final cost = workshop.creditsRequired;

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm booking'),
      content: Text(
        'Book "${workshop.title}"\n'
        '${_fmtDate2(slot.start)} • ${_fmtTime2(slot.start)}\n\n'
        'Cost: $cost credits\n'
        'Your credits: $creditsNow',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Book'),
        ),
      ],
    ),
  );

  if (ok != true) return;

  final result = store.bookSlot(workshopId: workshop.id, start: slot.start);

  if (!context.mounted) return;

  switch (result) {
    case BookResult.success:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booked! Credits deducted ✅')),
      );
      break;

    case BookResult.alreadyBooked:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already booked this slot ✅')),
      );
      break;

    case BookResult.insufficientCredits:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough credits 😭')),
      );
      break;

    case BookResult.full:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That slot is full. Try another one.')),
      );
      break;

    case BookResult.notFound:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot not found.')),
      );
      break;
  }
}

String _fmtDate2(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final wd = weekdays[d.weekday - 1];
  final mo = months[d.month - 1];
  final day = d.day.toString().padLeft(2, '0');
  return '$wd, $day $mo';
}

String _fmtTime2(DateTime d) {
  final h = d.hour;
  final m = d.minute.toString().padLeft(2, '0');
  final suffix = h >= 12 ? 'PM' : 'AM';
  final hh = (h % 12 == 0) ? 12 : (h % 12);
  return '$hh:$m $suffix';
}

