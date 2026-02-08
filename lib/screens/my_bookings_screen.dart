import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../state/skilltar_store.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Waitlist'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<Booking>>(
        valueListenable: SkilltarStore.I.bookings,
        builder: (context, bookings, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(SkilltarStore.I.getUpcomingBookings()),
              _buildBookingList(SkilltarStore.I.getBookingsByStatus(BookingStatus.waitlist)),
              _buildBookingList(SkilltarStore.I.getBookingsByStatus(BookingStatus.completed)),
              _buildBookingList(SkilltarStore.I.getBookingsByStatus(BookingStatus.cancelled)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(booking: bookings[index]);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.waitlist:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.waitlist:
        return 'WAITLIST';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  void _showCancelDialog(BuildContext context) {
    final canRefund = booking.canRefundCredits();
    final daysUntil = booking.slotStart.difference(DateTime.now()).inDays;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canRefund ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canRefund ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    canRefund ? Icons.check_circle : Icons.warning,
                    color: canRefund ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canRefund
                          ? '${booking.creditsSpent} credits will be refunded ($daysUntil days before workshop)'
                          : 'No refund - cancellation is within 3 days',
                      style: TextStyle(
                        fontSize: 13,
                        color: canRefund ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            onPressed: () {
              final refunded = SkilltarStore.I.cancelBooking(booking.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    refunded > 0
                        ? 'Booking cancelled. $refunded credits refunded.'
                        : 'Booking cancelled. No refund (late cancellation).',
                  ),
                  backgroundColor: refunded > 0 ? Colors.green : Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop image and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    booking.workshopImageAsset,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.workshopTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getStatusColor(booking.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusText(booking.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details
            _InfoRow(
              icon: Icons.location_on,
              text: booking.location,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today,
              text: _formatDateTime(booking.slotStart),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.access_time,
              text: _formatDuration(booking.slotDurationMinutes),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.stars,
              text: '${booking.creditsSpent} credits',
            ),

            // Action button (only for cancellable bookings)
            if (booking.isCancellable) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  icon: const Icon(Icons.close),
                  label: Text(
                    booking.canRefundCredits()
                        ? 'Cancel Booking (Refund ${booking.creditsSpent} credits)'
                        : 'Cancel (No Refund)',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}