import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password; // In production, use proper hashing

  @HiveField(4)
  String role; // 'public', 'volunteer', 'admin'

  @HiveField(5)
  String city;

  @HiveField(6)
  String phone;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.city,
    this.phone = '',
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'city': city,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isVolunteer => role == 'volunteer';
  bool get isPublic => role == 'public';
}
