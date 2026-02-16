import 'package:hive/hive.dart';

part 'reminder.g.dart';

enum ReminderScheduleType {
  dailyForever,
  untilDate,
  forDays,
}

@HiveType(typeId: 4)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String time;

  @HiveField(2)
  final List<ReminderMedicine> medicines;

  // 0 = dailyForever, 1 = untilDate, 2 = forDays
  @HiveField(3)
  final int scheduleType;

  // Local date (midnight) when the course starts.
  @HiveField(4)
  final DateTime startDate;

  // Inclusive end date (local midnight). Used when scheduleType == untilDate.
  @HiveField(5)
  final DateTime? endDate;

  // Number of days (inclusive). Used when scheduleType == forDays.
  @HiveField(6)
  final int? durationDays;

  Reminder({
    required this.id,
    required this.time,
    required this.medicines,
    this.scheduleType = 0,
    required this.startDate,
    this.endDate,
    this.durationDays,
  });

  ReminderScheduleType get schedule {
    switch (scheduleType) {
      case 1:
        return ReminderScheduleType.untilDate;
      case 2:
        return ReminderScheduleType.forDays;
      case 0:
      default:
        return ReminderScheduleType.dailyForever;
    }
  }

  DateTime? get effectiveEndDate {
    if (schedule == ReminderScheduleType.untilDate) return endDate;
    if (schedule == ReminderScheduleType.forDays) {
      final days = durationDays ?? 0;
      if (days <= 0) return null;
      return startDate.add(Duration(days: days - 1));
    }
    return null;
  }

  Reminder copyWith({
    String? id,
    String? time,
    List<ReminderMedicine>? medicines,
    int? scheduleType,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
  }) {
    return Reminder(
      id: id ?? this.id,
      time: time ?? this.time,
      medicines: medicines ?? this.medicines,
      scheduleType: scheduleType ?? this.scheduleType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
    );
  }
}

@HiveType(typeId: 5)
class ReminderMedicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final String unit;

  ReminderMedicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.unit,
  });

  ReminderMedicine copyWith({
    String? id,
    String? name,
    String? dose,
    String? unit,
  }) {
    return ReminderMedicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
    );
  }
}
