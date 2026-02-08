import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/workshop.dart';
import '../state/skilltar_store.dart';

class _SlotEntry {
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  int capacity;
  bool repeatWeekly;

  _SlotEntry({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.capacity = 10,
    this.repeatWeekly = false,
  });

  _SlotEntry copy() => _SlotEntry(
        date: date,
        startTime: startTime,
        endTime: endTime,
        capacity: capacity,
        repeatWeekly: repeatWeekly,
      );
}

class NewWorkshopListingScreen extends StatefulWidget {
  const NewWorkshopListingScreen({super.key});

  @override
  State<NewWorkshopListingScreen> createState() =>
      _NewWorkshopListingScreenState();
}

class _NewWorkshopListingScreenState extends State<NewWorkshopListingScreen> {
  final _store = SkilltarStore.I;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _category = 'Arts & Crafts';
  static const List<String> _categories = [
    'Arts & Crafts',
    'Tech',
    'Food',
    'Career',
    'Creative',
    'Lifestyle',
    'Media',
    'Finance',
  ];

  final List<_SlotEntry> _slots = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _slots.add(_SlotEntry(
      date: now,
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 30),
      capacity: 10,
      repeatWeekly: false,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addSlot() {
    setState(() {
      final last = _slots.isEmpty ? null : _slots.last;
      final base = last ?? _SlotEntry(
            date: DateTime.now(),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endTime: const TimeOfDay(hour: 11, minute: 30),
            capacity: 10,
            repeatWeekly: false,
          );
      _slots.add(base.copy());
    });
  }

  void _removeSlot(int index) {
    if (_slots.length <= 1) return;
    setState(() => _slots.removeAt(index));
  }

  Future<void> _pickDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _slots[index].date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _slots[index].date = picked);
    }
  }

  Future<void> _pickStartTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slots[index].startTime,
    );
    if (picked != null) {
      setState(() => _slots[index].startTime = picked);
    }
  }

  Future<void> _pickEndTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slots[index].endTime,
    );
    if (picked != null) {
      setState(() => _slots[index].endTime = picked);
    }
  }

  void _publish() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priceStr = _priceController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workshop title')),
      );
      return;
    }
    int credits = 8;
    if (priceStr.isNotEmpty) {
      credits = int.tryParse(priceStr) ?? 8;
    }
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final workshopSlots = _slots.map((e) {
      final start = DateTime(
        e.date.year,
        e.date.month,
        e.date.day,
        e.startTime.hour,
        e.startTime.minute,
      );
      final end = DateTime(
        e.date.year,
        e.date.month,
        e.date.day,
        e.endTime.hour,
        e.endTime.minute,
      );
      final durationMinutes = end.difference(start).inMinutes;
      return WorkshopSlot(
        start: start,
        durationMinutes: durationMinutes > 0 ? durationMinutes : 90,
        capacity: e.capacity,
        booked: 0,
      );
    }).toList();

    final workshop = Workshop(
      id: id,
      title: title,
      category: _category,
      creditsRequired: credits,
      rating: 4.0,
      location: 'TBD',
      description: description.isEmpty ? 'Workshop by host.' : description,
      tags: const [],
      imageAsset: 'assets/images/stock.png',
      slots: workshopSlots,
    );

    _store.workshops.value = [..._store.workshops.value, workshop];
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workshop published ✅')),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hh = (h % 12 == 0) ? 12 : (h % 12);
    return '$hh:$m $suffix';
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F0),
      appBar: AppBar(
        title: const Text(
          'New Workshop Listing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C2C2C),
          ),
        ),
        backgroundColor: const Color(0xFFE8F5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextField(
                    controller: _titleController,
                    hint: 'e.g., Ceramic Pot Making',
                    label: null,
                  ),
                  const SizedBox(height: 14),
                  _DropdownField(
                    value: _category,
                    items: _categories,
                    hint: 'e.g. Arts & Crafts',
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 14),
                  _TextField(
                    controller: _priceController,
                    hint: '',
                    label: 'Credit',
                    suffix: '\$',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3C3C3C),
                        ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Detail the experience, materials, what guests should bring...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_slots.length, (index) {
              final slot = _slots[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 20, color: Color(0xFF5A9B7A)),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A5A5A),
                            ),
                          ),
                          const Spacer(),
                          if (_slots.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeSlot(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickDate(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _formatDate(slot.date),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _pickStartTime(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE0E0E0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _formatTime(slot.startTime),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.access_time, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _pickEndTime(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE0E0E0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _formatTime(slot.endTime),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.access_time, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            'Capacity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (slot.capacity > 1) {
                                      setState(() =>
                                          _slots[index].capacity = slot.capacity - 1);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${slot.capacity}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() =>
                                        _slots[index].capacity = slot.capacity + 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Repeat weekly',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C3C),
                            ),
                          ),
                          Switch(
                            value: slot.repeatWeekly,
                            onChanged: (v) {
                              setState(() =>
                                  _slots[index].repeatWeekly = v);
                            },
                            activeColor: const Color(0xFF5A9B7A),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9762E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Publish Workshop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlot,
        backgroundColor: const Color(0xFF5A9B7A),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x0D000000),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: child,
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _TextField({
    required this.controller,
    required this.hint,
    this.label,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3C3C3C),
                ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E8E),
              fontWeight: FontWeight.w600,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF3C3C3C),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }
}
