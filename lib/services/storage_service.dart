import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/time_slot.dart';
import '../models/daily_progress.dart';

class StorageService extends ChangeNotifier {
  late Box<TimeSlot> _slotsBox;
  late Box<DailyProgress> _progressBox;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TimeSlotAdapter());
    Hive.registerAdapter(DailyProgressAdapter());

    _slotsBox = await Hive.openBox<TimeSlot>('time_slots');
    _progressBox = await Hive.openBox<DailyProgress>('daily_progress');
    
    _isInitialized = true;
    notifyListeners();
  }

  // Time Slots
  List<TimeSlot> getSlotsForDay(int dayOfWeek) {
    return _slotsBox.values.where((slot) => slot.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  Future<void> addTimeSlot(TimeSlot slot) async {
    await _slotsBox.put(slot.id, slot);
    notifyListeners();

  }

  Future<void> deleteTimeSlot(String id) async {
    await _slotsBox.delete(id);

    notifyListeners();
  }

  // Daily Progress
  DailyProgress getTodayProgress() {
    final today = DateTime.now();
    
    // Find progress for today
    final progressList = _progressBox.values.where((p) => isSameDay(p.date, today)).toList();
    
    if (progressList.isNotEmpty) {
      return progressList.first;
    } else {
      // Create new progress for today
      final newProgress = DailyProgress(date: today, completedSlotIds: []);
      _progressBox.add(newProgress);
      return newProgress;
    }
  }

  Future<void> toggleSlotCompletion(String slotId) async {
    final progress = getTodayProgress();
    final List<String> newCompleted = List.from(progress.completedSlotIds);
    
    if (newCompleted.contains(slotId)) {
      newCompleted.remove(slotId);
    } else {
      newCompleted.add(slotId);
    }
    
    // We need to create a new object or update the existing one carefully if it's immutable-ish
    // Hive objects are mutable if they extend HiveObject, but the list inside might need reassignment
    // Actually, since we generated the adapter, we can just update the field and call save()
    
    // However, the generated adapter might not handle list mutation well if we don't reassign
    // Let's just update the list and save.
    
    // Better: update the object in the box
    final index = _progressBox.values.toList().indexOf(progress);
    if (index != -1) {
       await _progressBox.putAt(index, DailyProgress(date: progress.date, completedSlotIds: newCompleted));
    }
    
    notifyListeners();
  }

  bool isSlotCompleted(String slotId) {
    final progress = getTodayProgress();
    return progress.completedSlotIds.contains(slotId);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
