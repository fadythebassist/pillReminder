import 'package:hive/hive.dart';

part 'medicine_dose.g.dart';

@HiveType(typeId: 2)
class MedicineDose extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineId;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String scheduledTime;

  @HiveField(4)
  final DateTime? takenAt;

  MedicineDose({
    required this.id,
    required this.medicineId,
    required this.date,
    required this.scheduledTime,
    this.takenAt,
  });

  String get storageKey => 'dose_${medicineId}_${date}_$scheduledTime';

  bool get isTaken => takenAt != null;

  MedicineDose copyWith({
    String? id,
    String? medicineId,
    String? date,
    String? scheduledTime,
    DateTime? takenAt,
  }) {
    return MedicineDose(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  MedicineDose clear() {
    return MedicineDose(
      id: id,
      medicineId: medicineId,
      date: date,
      scheduledTime: scheduledTime,
      takenAt: null,
    );
  }
}
