// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_dose.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineDoseAdapter extends TypeAdapter<MedicineDose> {
  @override
  final int typeId = 2;

  @override
  MedicineDose read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineDose(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      date: fields[2] as String,
      scheduledTime: fields[3] as String,
      takenAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineDose obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.takenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDoseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
