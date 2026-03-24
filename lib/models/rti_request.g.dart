part of 'rti_request.dart';

class RTIRequestAdapter extends TypeAdapter<RTIRequest> {
  @override
  final int typeId = 3;

  @override
  RTIRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RTIRequest(
      id: fields[0] as String,
      complaintId: fields[1] as String,
      department: fields[2] as String,
      requestText: fields[3] as String,
      responseText: fields[4] as String?,
      status: fields[5] as String,
      filedAt: fields[6] as DateTime,
      respondedAt: fields[7] as DateTime?,
      filedBy: fields[8] as String,
      filedByName: fields[9] as String,
      referenceNumber: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RTIRequest obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.complaintId)
      ..writeByte(2)
      ..write(obj.department)
      ..writeByte(3)
      ..write(obj.requestText)
      ..writeByte(4)
      ..write(obj.responseText)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.filedAt)
      ..writeByte(7)
      ..write(obj.respondedAt)
      ..writeByte(8)
      ..write(obj.filedBy)
      ..writeByte(9)
      ..write(obj.filedByName)
      ..writeByte(10)
      ..write(obj.referenceNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RTIRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
