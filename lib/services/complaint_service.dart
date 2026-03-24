import 'package:uuid/uuid.dart';
import '../models/complaint.dart';
import '../models/complaint_update.dart';
import '../models/rti_request.dart';
import '../models/user.dart';
import 'database_service.dart';

class ComplaintService {
  static final ComplaintService _instance = ComplaintService._internal();
  factory ComplaintService() => _instance;
  ComplaintService._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  /// Create a new complaint
  Future<Complaint> createComplaint({
    required String title,
    required String category,
    required String description,
    required String city,
    required String location,
    required UserModel user,
    int priority = 2,
  }) async {
    final id = await _db.generateComplaintId();
    final complaint = Complaint(
      id: id,
      title: title,
      category: category,
      description: description,
      city: city,
      userId: user.id,
      userName: user.name,
      location: location,
      priority: priority,
    );
    await _db.saveComplaint(complaint);

    // Add initial update
    await addUpdate(
      complaintId: id,
      message: 'Complaint filed by ${user.name}',
      user: user,
      newStatus: 'open',
    );

    return complaint;
  }

  /// Update complaint status
  Future<void> updateStatus({
    required String complaintId,
    required String newStatus,
    required String message,
    required UserModel user,
  }) async {
    final complaint = _db.getComplaint(complaintId);
    if (complaint == null) return;

    final oldStatus = complaint.status;
    complaint.status = newStatus;
    complaint.updatedAt = DateTime.now();
    await _db.saveComplaint(complaint);

    await addUpdate(
      complaintId: complaintId,
      message: message,
      user: user,
      previousStatus: oldStatus,
      newStatus: newStatus,
    );
  }

  /// Assign volunteer to complaint
  Future<void> assignVolunteer({
    required String complaintId,
    required UserModel volunteer,
    required UserModel assignedBy,
  }) async {
    final complaint = _db.getComplaint(complaintId);
    if (complaint == null) return;

    complaint.assignedVolunteerId = volunteer.id;
    complaint.assignedVolunteerName = volunteer.name;
    if (complaint.status == 'open') {
      complaint.status = 'in_progress';
    }
    complaint.updatedAt = DateTime.now();
    await _db.saveComplaint(complaint);

    await addUpdate(
      complaintId: complaintId,
      message: 'Assigned to volunteer: ${volunteer.name} by ${assignedBy.name}',
      user: assignedBy,
      previousStatus: complaint.status == 'in_progress' ? 'open' : null,
      newStatus: complaint.status == 'in_progress' ? 'in_progress' : null,
    );
  }

  /// Add a text update/note to a complaint
  Future<void> addUpdate({
    required String complaintId,
    required String message,
    required UserModel user,
    String? previousStatus,
    String? newStatus,
  }) async {
    final update = ComplaintUpdate(
      id: _uuid.v4(),
      complaintId: complaintId,
      message: message,
      previousStatus: previousStatus,
      newStatus: newStatus,
      updatedBy: user.id,
      updatedByName: user.name,
      updatedByRole: user.role,
    );
    await _db.saveUpdate(update);
  }

  /// Add external data (e.g., from ChatGPT) to complaint
  Future<void> addExternalData({
    required String complaintId,
    required String data,
    required UserModel user,
  }) async {
    final complaint = _db.getComplaint(complaintId);
    if (complaint == null) return;

    complaint.addExternalData(data);
    await _db.saveComplaint(complaint);

    await addUpdate(
      complaintId: complaintId,
      message: 'External data imported by ${user.name}',
      user: user,
    );
  }

  /// File an RTI request linked to a complaint
  Future<RTIRequest> fileRTI({
    required String complaintId,
    required String department,
    required String requestText,
    required UserModel user,
    String referenceNumber = '',
  }) async {
    final rti = RTIRequest(
      id: _uuid.v4(),
      complaintId: complaintId,
      department: department,
      requestText: requestText,
      filedBy: user.id,
      filedByName: user.name,
      referenceNumber: referenceNumber,
      status: referenceNumber.isNotEmpty ? 'filed' : 'drafted',
    );
    await _db.saveRTI(rti);

    await addUpdate(
      complaintId: complaintId,
      message: 'RTI request ${referenceNumber.isNotEmpty ? "filed" : "drafted"} to $department by ${user.name}',
      user: user,
    );

    return rti;
  }

  /// Update RTI response
  Future<void> updateRTIResponse({
    required RTIRequest rti,
    required String responseText,
    required UserModel user,
  }) async {
    rti.responseText = responseText;
    rti.status = 'responded';
    rti.respondedAt = DateTime.now();
    await _db.saveRTI(rti);

    await addUpdate(
      complaintId: rti.complaintId,
      message: 'RTI response received from ${rti.department}',
      user: user,
    );
  }

  /// Get complaints needing follow-up (no update in 3+ days)
  List<Complaint> getComplaintsNeedingFollowUp() {
    final threshold = DateTime.now().subtract(const Duration(days: 3));
    return _db.getAllComplaints().where((c) {
      return (c.status == 'open' || c.status == 'in_progress') &&
          c.updatedAt.isBefore(threshold);
    }).toList();
  }
}
