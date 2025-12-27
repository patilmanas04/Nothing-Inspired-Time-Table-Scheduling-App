import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nothing_timetable/main.dart';
import 'package:nothing_timetable/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:nothing_timetable/models/time_slot.dart';
import 'package:nothing_timetable/models/daily_progress.dart';

class MockStorageService extends StorageService {
  @override
  Future<void> init() async {
    // No-op for mock
  }

  @override
  List<TimeSlot> getSlotsForDay(int dayOfWeek) {
    return [];
  }

  @override
  DailyProgress getTodayProgress() {
    return DailyProgress(date: DateTime.now(), completedSlotIds: []);
  }
  
  @override
  bool isSlotCompleted(String slotId) => false;
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mockStorage = MockStorageService();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StorageService>.value(value: mockStorage),
        ],
        child: const NothingTimetableApp(),
      ),
    );

    // Verify that the Home Screen title is present
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('NO SCHEDULE'), findsOneWidget);
    
    // Verify Bottom Bar
    expect(find.byIcon(Icons.check_box_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_view_week_outlined), findsOneWidget);
    expect(find.byIcon(Icons.view_timeline_outlined), findsOneWidget);
  });
}
