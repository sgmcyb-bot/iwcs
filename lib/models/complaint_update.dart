import 'package:hive/hive.dart';

part 'complaint_update.g.dart';

@HiveType(typeId: 2)
class ComplaintUpdate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String complaintId;

  @HiveField(2)
  String message;

  @HiveField(3)
  String? previousStatus;

  @HiveField(4)
  String? newStatus;

  @HiveField(5)
  final String updatedBy; // user ID

  @HiveField(6)
  final String updatedByName;

  @HiveField(7)
  final String updatedByRole;

  @HiveField(8)
  final DateTime timestamp;

  ComplaintUpdate({
    required this.id,
    required this.complaintId,
    required this.message,
    this.previousStatus,
    this.newStatus,
    required this.updatedBy,
    required this.updatedByName,
    required this.updatedByRole,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isStatusChange => previousStatus != null && newStatus != null;
}
