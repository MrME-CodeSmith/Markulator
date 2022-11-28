// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkItemAdapter extends TypeAdapter<MarkItem> {
  @override
  final int typeId = 0;

  @override
  MarkItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkItem(
      name: fields[2] as String,
      mark: fields[3] as double,
      contributors: (fields[4] as HiveList).castHiveList(),
      weight: fields[5] as double,
      parent: fields[7] as MarkItem?,
      autoWeight: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MarkItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.mark)
      ..writeByte(4)
      ..write(obj.contributors)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.autoWeight)
      ..writeByte(7)
      ..write(obj.parent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
