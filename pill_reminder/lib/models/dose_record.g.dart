// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseRecordAdapter extends TypeAdapter<DoseRecord> {
  @override
  final int typeId = 0;

  @override
  DoseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseRecord(
      date: fields[0] as String,
      takenAt: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DoseRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.takenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
