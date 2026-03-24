part of 'complaint_update.dart';

class ComplaintUpdateAdapter extends TypeAdapter<ComplaintUpdate> {
  @override
  final int typeId = 2;

  @override
  ComplaintUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComplaintUpdate(
      id: fields[0] as String,
      complaintId: fields[1] as String,
      message: fields[2] as String,
      previousStatus: fields[3] as String?,
      newStatus: fields[4] as String?,
      updatedBy: fields[5] as String,
      updatedByName: fields[6] as String,
      updatedByRole: fields[7] as String,
      timestamp: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ComplaintUpdate obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.complaintId)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.previousStatus)
      ..writeByte(4)
      ..write(obj.newStatus)
      ..writeByte(5)
      ..write(obj.updatedBy)
      ..writeByte(6)
      ..write(obj.updatedByName)
      ..writeByte(7)
      ..write(obj.updatedByRole)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
