// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 4;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      time: fields[1] as String,
      medicines: (fields[2] as List).cast<ReminderMedicine>(),
      scheduleType: fields[3] as int,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      durationDays: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.medicines)
      ..writeByte(3)
      ..write(obj.scheduleType)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.durationDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderMedicineAdapter extends TypeAdapter<ReminderMedicine> {
  @override
  final int typeId = 5;

  @override
  ReminderMedicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderMedicine(
      id: fields[0] as String,
      name: fields[1] as String,
      dose: fields[2] as String,
      unit: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderMedicine obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dose)
      ..writeByte(3)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderMedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
