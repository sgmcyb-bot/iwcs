part of 'complaint.dart';

class ComplaintAdapter extends TypeAdapter<Complaint> {
  @override
  final int typeId = 1;

  @override
  Complaint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Complaint(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      city: fields[4] as String,
      status: fields[5] as String,
      userId: fields[6] as String,
      assignedVolunteerId: fields[7] as String?,
      assignedVolunteerName: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      location: fields[11] as String,
      userName: fields[12] as String,
      externalData: (fields[13] as List?)?.cast<String>() ?? [],
      priority: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Complaint obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.assignedVolunteerId)
      ..writeByte(8)
      ..write(obj.assignedVolunteerName)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(12)
      ..write(obj.userName)
      ..writeByte(13)
      ..write(obj.externalData)
      ..writeByte(14)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
