import 'package:flutter/material.dart';
import '../models/workshop.dart';

class WorkshopDetailsScreen extends StatelessWidget {
  final Workshop workshop;
  const WorkshopDetailsScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.tertiaryContainer,
                        ],
                      ),
                    ),
                    child: const Center(child: Icon(Icons.image, size: 34)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(workshop.category)),
                            ...workshop.tags.map((t) => Chip(label: Text(t))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(workshop.description),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(workshop.location)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${workshop.creditsRequired} credits • ⭐ ${workshop.rating.toStringAsFixed(1)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Text(
              'Available slots',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            ...workshop.slots.map((slot) => _slotCard(context, slot)),

            const SizedBox(height: 12),
            Text(
              'Note: booking closes once capacity is reached.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _slotCard(BuildContext context, WorkshopSlot slot) {
    final isFull = slot.isFull;

    return Card(
      child: ListTile(
        enabled: !isFull,
        title: Text(_formatSlot(slot)),
        subtitle: Text('Capacity ${slot.booked}/${slot.capacity}'),
        trailing: isFull
            ? IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notify feature: TODO (waitlist)')),
                  );
                },
                icon: const Icon(Icons.notifications),
                tooltip: 'Notify me',
              )
            : FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking: TODO (credits deduction)')),
                  );
                },
                child: const Text('Book'),
              ),
      ),
    );
  }

  String _formatSlot(WorkshopSlot slot) {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = slot.start;
    final startTime = '${two(d.hour)}:${two(d.minute)}';
    final e = slot.end;
    final endTime = '${two(e.hour)}:${two(e.minute)}';
    final date = '${d.day}/${two(d.month)}/${d.year}';
    return '$date • $startTime - $endTime';
  }
}
