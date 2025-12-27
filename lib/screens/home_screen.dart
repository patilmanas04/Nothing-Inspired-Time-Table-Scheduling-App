import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

import '../theme/nothing_theme.dart';
import '../widgets/nothing_widgets.dart';
import 'edit_schedule_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final today = DateTime.now();
    final weekday = today.weekday; // 1 = Mon, 7 = Sun
    final slots = storage.getSlotsForDay(weekday);
    // Ensure progress is initialized for today
    storage.getTodayProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODAY'),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Text(
                    'Settings',
                    style: GoogleFonts.jetBrainsMono(),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getWeekdayName(weekday).toUpperCase(),
              style: GoogleFonts.orbitron(
                textStyle: Theme.of(context).textTheme.displayLarge,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${today.day} ${_getMonthName(today.month)} ${today.year}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: NothingTheme.grey,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: slots.isEmpty
                  ? Center(
                      child: Text(
                        'NO SCHEDULE',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: NothingTheme.grey,
                            ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: slots.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final isDone = storage.isSlotCompleted(slot.id);
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        
                        return NothingCard(
                          borderWidth: 0,
                          backgroundColor: isDark ? const Color(0xFF1C1C1C) : NothingTheme.offWhite,
                          onTap: () => storage.toggleSlotCompletion(slot.id),
                          child: Row(
                            children: [
                              if (slot.iconCode != null) ...[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark ? NothingTheme.white : NothingTheme.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    IconData(slot.iconCode!, fontFamily: 'MaterialIcons'),
                                    color: isDark ? NothingTheme.black : NothingTheme.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatTime(slot.startMinutes)} - ${_formatTime(slot.endMinutes)}',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: NothingTheme.red,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      slot.title.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                            color: isDone ? NothingTheme.grey : Theme.of(context).colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDone ? NothingTheme.green : NothingTheme.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isDone ? 'COMPLETED' : 'PENDING',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: NothingTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              NothingCheckbox(
                                value: isDone,
                                borderWidth: 1.0,
                                onChanged: (val) {
                                  storage.toggleSlotCompletion(slot.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $ampm';
  }
}
