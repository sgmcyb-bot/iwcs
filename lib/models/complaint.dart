import 'package:hive/hive.dart';

part 'complaint.g.dart';

@HiveType(typeId: 1)
class Complaint extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category; // plastic_waste, river_pollution, deforestation, construction, other

  @HiveField(3)
  String description;

  @HiveField(4)
  String city;

  @HiveField(5)
  String status; // open, in_progress, resolved, closed

  @HiveField(6)
  final String userId;

  @HiveField(7)
  String? assignedVolunteerId;

  @HiveField(8)
  String? assignedVolunteerName;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  String location; // Specific address / area

  @HiveField(12)
  String userName;

  @HiveField(13)
  List<String> externalData; // Imported text data (e.g., from ChatGPT)

  @HiveField(14)
  int priority; // 1=low, 2=medium, 3=high

  Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.city,
    required this.userId,
    required this.userName,
    this.status = 'open',
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    this.location = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? externalData,
    this.priority = 2,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        externalData = externalData ?? [];

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isAssigned => assignedVolunteerId != null;

  void addExternalData(String data) {
    externalData.add('[${DateTime.now().toIso8601String()}] $data');
    updatedAt = DateTime.now();
  }
}
