import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../models/complaint_update.dart';
import '../models/rti_request.dart';
import '../models/user.dart';
import '../services/complaint_service.dart';
import '../services/database_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter state
  String? _cityFilter;
  String? _statusFilter;
  String? _categoryFilter;

  String? get cityFilter => _cityFilter;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  // === Getters ===

  List<Complaint> getAllComplaints() {
    var complaints = _db.getAllComplaints();
    complaints = _applyFilters(complaints);
    complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return complaints;
  }

  List<Complaint> getMyComplaints(String userId) {
    var complaints = _db.getComplaintsByUser(userId);
    complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return complaints;
  }

  List<Complaint> getVolunteerComplaints(String volunteerId) {
    var complaints = _db.getComplaintsByVolunteer(volunteerId);
    complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return complaints;
  }

  List<Complaint> getComplaintsByCity(String city) {
    var complaints = _db.getComplaintsByCity(city);
    complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return complaints;
  }

  Complaint? getComplaint(String id) => _db.getComplaint(id);

  List<ComplaintUpdate> getUpdates(String complaintId) =>
      _db.getUpdatesForComplaint(complaintId);

  List<RTIRequest> getRTIs(String complaintId) =>
      _db.getRTIForComplaint(complaintId);

  Map<String, int> getStats() => _db.getComplaintStats();
  Map<String, int> getCityStats() => _db.getCityStats();
  Map<String, int> getCategoryStats() => _db.getCategoryStats();

  // === Filters ===

  void setFilters({String? city, String? status, String? category}) {
    _cityFilter = city;
    _statusFilter = status;
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _cityFilter = null;
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  List<Complaint> _applyFilters(List<Complaint> complaints) {
    if (_cityFilter != null) {
      complaints = complaints.where((c) => c.city == _cityFilter).toList();
    }
    if (_statusFilter != null) {
      complaints = complaints.where((c) => c.status == _statusFilter).toList();
    }
    if (_categoryFilter != null) {
      complaints =
          complaints.where((c) => c.category == _categoryFilter).toList();
    }
    return complaints;
  }

  // === Actions ===

  Future<Complaint?> createComplaint({
    required String title,
    required String category,
    required String description,
    required String city,
    required String location,
    required UserModel user,
    int priority = 2,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final complaint = await _complaintService.createComplaint(
        title: title,
        category: category,
        description: description,
        city: city,
        location: location,
        user: user,
        priority: priority,
      );
      _isLoading = false;
      notifyListeners();
      return complaint;
    } catch (e) {
      _errorMessage = 'Failed to create complaint: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateStatus({
    required String complaintId,
    required String newStatus,
    required String message,
    required UserModel user,
  }) async {
    await _complaintService.updateStatus(
      complaintId: complaintId,
      newStatus: newStatus,
      message: message,
      user: user,
    );
    notifyListeners();
  }

  Future<void> assignVolunteer({
    required String complaintId,
    required UserModel volunteer,
    required UserModel assignedBy,
  }) async {
    await _complaintService.assignVolunteer(
      complaintId: complaintId,
      volunteer: volunteer,
      assignedBy: assignedBy,
    );
    notifyListeners();
  }

  Future<void> addNote({
    required String complaintId,
    required String message,
    required UserModel user,
  }) async {
    await _complaintService.addUpdate(
      complaintId: complaintId,
      message: message,
      user: user,
    );
    notifyListeners();
  }

  Future<void> addExternalData({
    required String complaintId,
    required String data,
    required UserModel user,
  }) async {
    await _complaintService.addExternalData(
      complaintId: complaintId,
      data: data,
      user: user,
    );
    notifyListeners();
  }

  Future<RTIRequest?> fileRTI({
    required String complaintId,
    required String department,
    required String requestText,
    required UserModel user,
    String referenceNumber = '',
  }) async {
    try {
      final rti = await _complaintService.fileRTI(
        complaintId: complaintId,
        department: department,
        requestText: requestText,
        user: user,
        referenceNumber: referenceNumber,
      );
      notifyListeners();
      return rti;
    } catch (e) {
      _errorMessage = 'Failed to file RTI: $e';
      notifyListeners();
      return null;
    }
  }

  List<Complaint> getComplaintsByStatus(String status) {
    return _db.getAllComplaints().where((c) => c.status == status).toList();
  }

  List<Complaint> getFollowUpNeeded() {
    return _complaintService.getComplaintsNeedingFollowUp();
  }
}
