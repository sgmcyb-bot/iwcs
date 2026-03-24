import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/complaint.dart';
import '../models/complaint_update.dart';
import '../models/rti_request.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === User Operations ===

  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.email.toLowerCase()).set({
      'id': user.id,
      'name': user.name,
      'email': user.email.toLowerCase(),
      'role': user.role,
      'city': user.city,
      'phone': user.phone,
      'isActive': user.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String email) async {
    final doc = await _db.collection('users').doc(email.toLowerCase()).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: '', // Password not stored in Firestore, managed by FirebaseAuth
      role: data['role'] ?? 'public',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  // === Complaint Operations ===

  Future<void> saveComplaint(Complaint complaint) async {
    await _db.collection('complaints').doc(complaint.id).set({
      'id': complaint.id,
      'title': complaint.title,
      'category': complaint.category,
      'description': complaint.description,
      'city': complaint.city,
      'status': complaint.status,
      'userId': complaint.userId,
      'userName': complaint.userName,
      'assignedVolunteerId': complaint.assignedVolunteerId,
      'assignedVolunteerName': complaint.assignedVolunteerName,
      'createdAt': complaint.createdAt.toIso8601String(),
      'updatedAt': complaint.updatedAt.toIso8601String(),
      'location': complaint.location,
      'externalData': complaint.externalData,
      'priority': complaint.priority,
    }, SetOptions(merge: true));
  }

  Stream<List<Complaint>> getComplaintsStream() {
    return _db.collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToComplaint(doc)).toList());
  }

  Complaint _mapDocToComplaint(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: data['id'],
      title: data['title'],
      category: data['category'],
      description: data['description'],
      city: data['city'],
      userId: data['userId'],
      userName: data['userName'],
      status: data['status'],
      assignedVolunteerId: data['assignedVolunteerId'],
      assignedVolunteerName: data['assignedVolunteerName'],
      location: data['location'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      externalData: List<String>.from(data['externalData'] ?? []),
      priority: data['priority'] ?? 2,
    );
  }

  // === RTI and Updates ===

  Future<void> saveComplaintUpdate(ComplaintUpdate update) async {
    await _db.collection('updates').doc(update.id).set({
      'id': update.id,
      'complaintId': update.complaintId,
      'message': update.message,
      'updatedById': update.updatedById,
      'updatedByName': update.updatedByName,
      'timestamp': update.timestamp.toIso8601String(),
      'isStatusChange': update.isStatusChange,
      'previousStatus': update.previousStatus,
      'newStatus': update.newStatus,
    });
  }

  Future<void> saveRTIRequest(RTIRequest request) async {
    await _db.collection('rtis').doc(request.id).set({
      'id': request.id,
      'complaintId': request.complaintId,
      'department': request.department,
      'requestText': request.requestText,
      'responseText': request.responseText,
      'status': request.status,
      'filedById': request.filedById,
      'filedByName': request.filedByName,
      'filedAt': request.filedAt.toIso8601String(),
      'referenceNumber': request.referenceNumber,
    });
  }
}
