import 'package:hive/hive.dart';

part 'rti_request.g.dart';

@HiveType(typeId: 3)
class RTIRequest extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String complaintId;

  @HiveField(2)
  String department; // Department the RTI is filed to

  @HiveField(3)
  String requestText;

  @HiveField(4)
  String? responseText;

  @HiveField(5)
  String status; // 'drafted', 'filed', 'responded', 'appealed'

  @HiveField(6)
  final DateTime filedAt;

  @HiveField(7)
  DateTime? respondedAt;

  @HiveField(8)
  final String filedBy; // user ID

  @HiveField(9)
  final String filedByName;

  @HiveField(10)
  String referenceNumber; // RTI reference number

  RTIRequest({
    required this.id,
    required this.complaintId,
    required this.department,
    required this.requestText,
    this.responseText,
    this.status = 'drafted',
    DateTime? filedAt,
    this.respondedAt,
    required this.filedBy,
    required this.filedByName,
    this.referenceNumber = '',
  }) : filedAt = filedAt ?? DateTime.now();

  bool get isDrafted => status == 'drafted';
  bool get isFiled => status == 'filed';
  bool get isResponded => status == 'responded';
  bool get isAppealed => status == 'appealed';
}
