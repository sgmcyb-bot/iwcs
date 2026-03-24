import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/complaint.dart';
import '../models/complaint_update.dart';
import '../models/rti_request.dart';
import '../config/constants.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<UserModel> _usersBox;
  late Box<Complaint> _complaintsBox;
  late Box<ComplaintUpdate> _updatesBox;
  late Box<RTIRequest> _rtiBox;
  late Box _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ComplaintAdapter());
    Hive.registerAdapter(ComplaintUpdateAdapter());
    Hive.registerAdapter(RTIRequestAdapter());

    // Open boxes
    _usersBox = await Hive.openBox<UserModel>(AppConstants.usersBox);
    _complaintsBox = await Hive.openBox<Complaint>(AppConstants.complaintsBox);
    _updatesBox = await Hive.openBox<ComplaintUpdate>(AppConstants.updatesBox);
    _rtiBox = await Hive.openBox<RTIRequest>(AppConstants.rtiBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);

    // Seed default admin and demo accounts if first run
    await _seedDefaultData();
  }

  Future<void> _seedDefaultData() async {
    if (_usersBox.isEmpty) {
      const uuid = Uuid();

      // Admin account
      await _usersBox.put(
        'admin@iwcs.org',
        UserModel(
          id: uuid.v4(),
          name: 'Admin User',
          email: 'admin@iwcs.org',
          password: 'admin123',
          role: AppConstants.roleAdmin,
          city: 'Delhi',
          phone: '+91 9999900000',
        ),
      );

      // Volunteer accounts
      await _usersBox.put(
        'volunteer@iwcs.org',
        UserModel(
          id: uuid.v4(),
          name: 'Priya Sharma',
          email: 'volunteer@iwcs.org',
          password: 'vol123',
          role: AppConstants.roleVolunteer,
          city: 'Mumbai',
          phone: '+91 9999911111',
        ),
      );

      await _usersBox.put(
        'volunteer2@iwcs.org',
        UserModel(
          id: uuid.v4(),
          name: 'Rahul Kumar',
          email: 'volunteer2@iwcs.org',
          password: 'vol123',
          role: AppConstants.roleVolunteer,
          city: 'Delhi',
          phone: '+91 9999922222',
        ),
      );

      // Public user account
      await _usersBox.put(
        'user@iwcs.org',
        UserModel(
          id: uuid.v4(),
          name: 'Amit Patel',
          email: 'user@iwcs.org',
          password: 'user123',
          role: AppConstants.rolePublic,
          city: 'Mumbai',
          phone: '+91 9999933333',
        ),
      );

      // Seed some sample complaints
      await _seedSampleComplaints();
    }
  }

  Future<void> _seedSampleComplaints() async {
    const uuid = Uuid();
    final publicUser = _usersBox.get('user@iwcs.org')!;
    final volunteer = _usersBox.get('volunteer@iwcs.org')!;

    // Complaint 1
    final c1Id = 'IWC-${DateTime.now().year}-0001';
    final c1 = Complaint(
      id: c1Id,
      title: 'Plastic waste dumping near Juhu Beach',
      category: 'plastic_waste',
      description: 'Large amounts of plastic waste being dumped near the Juhu Beach promenade. Multiple garbage bins overflowing and waste scattered along the shore.',
      city: 'Mumbai',
      userId: publicUser.id,
      userName: publicUser.name,
      status: 'in_progress',
      assignedVolunteerId: volunteer.id,
      assignedVolunteerName: volunteer.name,
      location: 'Juhu Beach, Andheri West',
      priority: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );
    await _complaintsBox.put(c1Id, c1);

    // Add update for complaint 1
    await _updatesBox.put(
      uuid.v4(),
      ComplaintUpdate(
        id: uuid.v4(),
        complaintId: c1Id,
        message: 'Complaint received. Assigning to local volunteer.',
        previousStatus: 'open',
        newStatus: 'in_progress',
        updatedBy: 'system',
        updatedByName: 'System',
        updatedByRole: 'admin',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    );

    // Complaint 2
    final c2Id = 'IWC-${DateTime.now().year}-0002';
    final c2 = Complaint(
      id: c2Id,
      title: 'Industrial waste in Yamuna River',
      category: 'river_pollution',
      description: 'Factory effluents being discharged directly into Yamuna river near Wazirabad. Water has turned dark with strong chemical odor.',
      city: 'Delhi',
      userId: publicUser.id,
      userName: publicUser.name,
      status: 'open',
      location: 'Wazirabad Barrage Area',
      priority: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    await _complaintsBox.put(c2Id, c2);

    // Complaint 3
    final c3Id = 'IWC-${DateTime.now().year}-0003';
    final c3 = Complaint(
      id: c3Id,
      title: 'Illegal tree cutting in Aarey Colony',
      category: 'deforestation',
      description: 'Over 20 trees have been cut down without permission in Aarey Colony for construction purposes. Need immediate intervention.',
      city: 'Mumbai',
      userId: publicUser.id,
      userName: publicUser.name,
      status: 'resolved',
      assignedVolunteerId: volunteer.id,
      assignedVolunteerName: volunteer.name,
      location: 'Aarey Colony, Goregaon',
      priority: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    await _complaintsBox.put(c3Id, c3);
  }

  // === User Operations ===

  UserModel? getUser(String email) => _usersBox.get(email);

  List<UserModel> getAllUsers() => _usersBox.values.toList();

  List<UserModel> getUsersByRole(String role) =>
      _usersBox.values.where((u) => u.role == role).toList();

  List<UserModel> getUsersByCity(String city) =>
      _usersBox.values.where((u) => u.city == city).toList();

  List<UserModel> getVolunteersByCity(String city) =>
      _usersBox.values.where((u) => u.role == 'volunteer' && u.city == city).toList();

  Future<void> saveUser(UserModel user) async {
    await _usersBox.put(user.email, user);
  }

  Future<void> deleteUser(String email) async {
    await _usersBox.delete(email);
  }

  // === Complaint Operations ===

  List<Complaint> getAllComplaints() => _complaintsBox.values.toList();

  Complaint? getComplaint(String id) => _complaintsBox.get(id);

  List<Complaint> getComplaintsByUser(String userId) =>
      _complaintsBox.values.where((c) => c.userId == userId).toList();

  List<Complaint> getComplaintsByCity(String city) =>
      _complaintsBox.values.where((c) => c.city == city).toList();

  List<Complaint> getComplaintsByStatus(String status) =>
      _complaintsBox.values.where((c) => c.status == status).toList();

  List<Complaint> getComplaintsByCategory(String category) =>
      _complaintsBox.values.where((c) => c.category == category).toList();

  List<Complaint> getComplaintsByVolunteer(String volunteerId) =>
      _complaintsBox.values
          .where((c) => c.assignedVolunteerId == volunteerId)
          .toList();

  Future<String> generateComplaintId() async {
    final year = DateTime.now().year;
    final count = _complaintsBox.length + 1;
    return 'IWC-$year-${count.toString().padLeft(4, '0')}';
  }

  Future<void> saveComplaint(Complaint complaint) async {
    await _complaintsBox.put(complaint.id, complaint);
  }

  Future<void> deleteComplaint(String id) async {
    await _complaintsBox.delete(id);
  }

  // === Complaint Update Operations ===

  List<ComplaintUpdate> getUpdatesForComplaint(String complaintId) {
    final updates = _updatesBox.values
        .where((u) => u.complaintId == complaintId)
        .toList();
    updates.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return updates;
  }

  Future<void> saveUpdate(ComplaintUpdate update) async {
    await _updatesBox.put(update.id, update);
  }

  // === RTI Operations ===

  List<RTIRequest> getRTIForComplaint(String complaintId) {
    final rtis = _rtiBox.values
        .where((r) => r.complaintId == complaintId)
        .toList();
    rtis.sort((a, b) => b.filedAt.compareTo(a.filedAt));
    return rtis;
  }

  List<RTIRequest> getAllRTI() => _rtiBox.values.toList();

  Future<void> saveRTI(RTIRequest rti) async {
    await _rtiBox.put(rti.id, rti);
  }

  // === Stats ===

  Map<String, int> getComplaintStats() {
    final all = _complaintsBox.values;
    return {
      'total': all.length,
      'open': all.where((c) => c.status == 'open').length,
      'in_progress': all.where((c) => c.status == 'in_progress').length,
      'resolved': all.where((c) => c.status == 'resolved').length,
      'closed': all.where((c) => c.status == 'closed').length,
    };
  }

  Map<String, int> getCityStats() {
    final stats = <String, int>{};
    for (var complaint in _complaintsBox.values) {
      stats[complaint.city] = (stats[complaint.city] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (var complaint in _complaintsBox.values) {
      stats[complaint.category] = (stats[complaint.category] ?? 0) + 1;
    }
    return stats;
  }

  // === Settings ===

  dynamic getSetting(String key) => _settingsBox.get(key);

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
}
