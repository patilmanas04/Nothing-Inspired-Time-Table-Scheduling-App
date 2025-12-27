import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../theme/nothing_theme.dart';
import '../models/time_slot.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime tempDate = _selectedDate;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = Theme.of(context).colorScheme.onSurface;
        final backgroundColor = isDark ? const Color(0xFF1A1A1A) : NothingTheme.white;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              content: SizedBox(
                width: 330,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT DATE',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('E, MMM d').format(tempDate),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: textColor,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 8),
                    
                    // Calendar
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark 
                          ? const ColorScheme.dark(
                              primary: NothingTheme.white,
                              onPrimary: NothingTheme.black,
                              onSurface: NothingTheme.white,
                            )
                          : const ColorScheme.light(
                              primary: NothingTheme.black,
                              onPrimary: NothingTheme.white,
                              onSurface: NothingTheme.black,
                            ),
                        textTheme: TextTheme(
                          bodyLarge: GoogleFonts.jetBrainsMono(color: textColor),
                          bodyMedium: GoogleFonts.jetBrainsMono(color: textColor),
                          bodySmall: GoogleFonts.jetBrainsMono(color: textColor),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                        onDateChanged: (date) {
                          setState(() => tempDate = date);
                        },
                      ),
                    ),
                    
                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: NothingTheme.grey,
                              textStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context, tempDate),
                            style: TextButton.styleFrom(
                              backgroundColor: textColor,
                              foregroundColor: isDark ? NothingTheme.black : NothingTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy • EEEE').format(_selectedDate).toUpperCase();
    final storage = Provider.of<StorageService>(context);
    final slots = storage.getSlotsForDay(_selectedDate.weekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMELINE'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: NothingTheme.red),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (!_isSameDay(_selectedDate, DateTime.now()))
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: NothingTheme.red),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'TODAY',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: NothingTheme.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _TimelineView(slots: slots, selectedDate: _selectedDate),
          ),
        ],
      ),
    );
  }
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TimelineView extends StatelessWidget {
  final List<TimeSlot> slots;
  final DateTime selectedDate;
  static const double hourWidth = 100.0;
  static const double startPadding = 24.0;

  const _TimelineView({required this.slots, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    final currentMinutes = now.hour * 60 + now.minute;
    final totalWidth = startPadding + (hourWidth * 24) + startPadding;
    
    // Calculate required height based on slots
    // Base height + padding + (slots count * slot height)
    final double slotHeight = 60.0;
    final double slotSpacing = 10.0;
    final double requiredHeight = 100.0 + (slots.length * (slotHeight + slotSpacing));
    final double totalHeight = MediaQuery.of(context).size.height > requiredHeight 
        ? MediaQuery.of(context).size.height 
        : requiredHeight;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
          children: [
            // Time Grid
            ...List.generate(25, (index) {
              final left = startPadding + index * hourWidth;
              return Positioned(
                left: left,
                top: 0,
                bottom: 0,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: Column(
                    children: [
                      Text(
                        '${index.toString().padLeft(2, '0')}:00',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: NothingTheme.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: 1,
                          color: NothingTheme.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Slots
            ...slots.map((slot) {
              final left = startPadding + (slot.startMinutes / 60) * hourWidth;
              final width = ((slot.endMinutes - slot.startMinutes) / 60) * hourWidth;
              
              final index = slots.indexOf(slot);
              final top = 50.0 + index * (slotHeight + slotSpacing); 

              // Color Logic
              final storage = Provider.of<StorageService>(context, listen: false);
              final isDone = storage.isSlotCompleted(slot.id);
              
              // Check if slot is missed (current time > end time AND not done)
              // Only applicable if looking at today's schedule
              bool isMissed = false;
              if (isToday && !isDone) {
                if (currentMinutes > slot.endMinutes) {
                  isMissed = true;
                }
              }
              // Also if looking at past days, all non-done slots are missed?
              // User said: "if the current time exeeds the maximum time range of the slot"
              // This implies mostly for today. For past days, technically current time > end time too.
              if (selectedDate.isBefore(DateTime(now.year, now.month, now.day)) && !isDone) {
                 isMissed = true;
              }

              Color bgColor = NothingTheme.white;
              Color textColor = NothingTheme.black;
              Color borderColor = NothingTheme.black;

              if (isDone) {
                bgColor = NothingTheme.green; // We need to define this or use standard green
                // NothingTheme doesn't have green, let's use a standard green that fits
                bgColor = const Color(0xFF00C853); 
                textColor = NothingTheme.white;
                borderColor = const Color(0xFF00C853);
              } else if (isMissed) {
                bgColor = NothingTheme.red;
                textColor = NothingTheme.white;
                borderColor = NothingTheme.red;
              }

              // Adjust layout for small slots
              final isSmallSlot = width < 50;
              final padding = isSmallSlot ? const EdgeInsets.symmetric(horizontal: 2, vertical: 4) : const EdgeInsets.all(8);
              final showIcon = !isSmallSlot && slot.iconCode != null;

              return Positioned(
                left: left,
                top: top,
                width: width,
                height: slotHeight,
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      BoxShadow(
                        color: NothingTheme.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (showIcon) ...[
                        Icon(
                          IconData(slot.iconCode!, fontFamily: 'MaterialIcons'),
                          color: textColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot.title,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_formatTime(slot.startMinutes)} - ${_formatTime(slot.endMinutes)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: textColor.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Current Time Indicator
            if (isToday)
              Positioned(
                left: startPadding + (currentMinutes / 60) * hourWidth,
                top: 20,
                bottom: 0,
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: NothingTheme.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: NothingTheme.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
