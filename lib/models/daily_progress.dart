import 'package:hive/hive.dart';

part 'daily_progress.g.dart';

@HiveType(typeId: 1)
class DailyProgress extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<String> completedSlotIds;

  DailyProgress({
    required this.date,
    required this.completedSlotIds,
  });
}
