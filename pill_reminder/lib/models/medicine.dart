import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 1)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final List<String> times;

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.unit,
    required this.times,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    String? unit,
    List<String>? times,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      times: times ?? this.times,
    );
  }
}
