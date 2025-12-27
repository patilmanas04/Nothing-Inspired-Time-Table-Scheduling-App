import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'time_slot.g.dart';

@HiveType(typeId: 0)
class TimeSlot extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int startMinutes; // Minutes from midnight

  @HiveField(3)
  final int endMinutes; // Minutes from midnight

  @HiveField(4)
  final int dayOfWeek; // 1 = Monday, 7 = Sunday

  @HiveField(5)
  final int? iconCode;

  TimeSlot({
    required this.id,
    required this.title,
    required this.startMinutes,
    required this.endMinutes,
    required this.dayOfWeek,
    this.iconCode,
  });

  factory TimeSlot.create({
    required String title,
    required int startMinutes,
    required int endMinutes,
    required int dayOfWeek,
    int? iconCode,
  }) {
    return TimeSlot(
      id: const Uuid().v4(),
      title: title,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      dayOfWeek: dayOfWeek,
      iconCode: iconCode,
    );
  }
}
