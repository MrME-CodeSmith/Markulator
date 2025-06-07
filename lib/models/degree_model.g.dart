// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'degree_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DegreeAdapter extends TypeAdapter<Degree> {
  @override
  final int typeId = 2;

  @override
  Degree read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Degree(
      name: fields[2] as String,
      years: (fields[3] as HiveList).castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, Degree obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.years);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DegreeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
