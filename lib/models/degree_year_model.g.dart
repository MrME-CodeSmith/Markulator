// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'degree_year_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DegreeYearAdapter extends TypeAdapter<DegreeYear> {
  @override
  final int typeId = 1;

  @override
  DegreeYear read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DegreeYear(
      yearIndex: fields[2] as int,
      modules: (fields[3] as HiveList).castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, DegreeYear obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.yearIndex)
      ..writeByte(3)
      ..write(obj.modules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DegreeYearAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
