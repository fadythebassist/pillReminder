import 'package:hive/hive.dart';

part 'dose_record.g.dart';

@HiveType(typeId: 0)
class DoseRecord extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final DateTime? takenAt;

  DoseRecord({
    required this.date,
    this.takenAt,
  });

  String get storageKey => 'dose_$date';

  bool get isTaken => takenAt != null;

  DoseRecord copyWith({
    String? date,
    DateTime? takenAt,
  }) {
    return DoseRecord(
      date: date ?? this.date,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  DoseRecord clear() {
    return DoseRecord(date: date, takenAt: null);
  }
}
