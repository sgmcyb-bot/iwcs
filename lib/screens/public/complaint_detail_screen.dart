import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common_widgets.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final auth = context.watch<AuthProvider>();
    final complaint = provider.getComplaint(widget.complaintId);
    final user = auth.currentUser!;

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Casework Missing')),
        body: const Center(child: Text('This complaint was not found.')),
      );
    }

    final categoryColor = AppTheme.getCategoryColor(complaint.category);
    final updates = provider.getUpdates(complaint.id);
    final rtis = provider.getRTIs(complaint.id);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                complaint.id,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            StatusBadge(status: complaint.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          complaint.title,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white.withValues(alpha: 0.05),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Case Details'),
                    Tab(text: 'Timeline'),
                    Tab(text: 'RTI Filings'),
                    Tab(text: 'Intelligence'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(complaint),
            _buildTimelineTab(updates),
            _buildRTITab(complaint, rtis, user),
            _buildExternalDataTab(complaint, user),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBar(complaint, user),
    );
  }

  Widget _buildDetailsTab(complaint) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInUp(
          child: _detailCard(
            title: 'CASWORK PROFILE',
            child: Column(
              children: [
                _detailItem(Icons.category_rounded, 'Category', AppTheme.getCategoryLabel(complaint.category)),
                const Divider(),
                _detailItem(Icons.priority_high_rounded, 'Priority', complaint.priority == 3 ? 'Critical' : (complaint.priority == 2 ? 'Medium' : 'Standard')),
                const Divider(),
                _detailItem(Icons.location_on_rounded, 'Location', '${complaint.location}, ${complaint.city}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: _detailCard(
            title: 'DESCRIPTION',
            child: Text(
              complaint.description,
              style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: AppTheme.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: _detailCard(
            title: 'AUDIT LOG',
            child: Column(
              children: [
                _detailItem(Icons.person_rounded, 'Reported By', complaint.userName),
                const Divider(),
                _detailItem(Icons.calendar_today_rounded, 'Filed On', _formatDate(complaint.createdAt)),
                if (complaint.isAssigned) ...[
                  const Divider(),
                  _detailItem(Icons.contact_support_rounded, 'Assigned Case Officer', complaint.assignedVolunteerName ?? 'Pending'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(List updates) {
    if (updates.isEmpty) {
      return _emptyState('No history available for this casework');
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TimelineWidget(
          entries: updates.map<TimelineEntry>((u) => TimelineEntry(
            message: u.message,
            byName: u.updatedByName,
            timestamp: u.timestamp,
            isStatusChange: u.isStatusChange,
            previousStatus: u.previousStatus,
            newStatus: u.newStatus,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRTITab(complaint, List rtis, user) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            if (rtis.isEmpty)
              _emptyState('No RTI inquiries filed yet')
            else
              ...rtis.map((rti) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _badge('DEPARTMENT', AppTheme.primaryBlue),
                        const Spacer(),
                        StatusBadge(status: rti.status, fontSize: 10),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(rti.department, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(rti.requestText, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
                    if (rti.referenceNumber.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.tag_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Ref: ${rti.referenceNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ],
                ),
              )),
          ],
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: ElevatedButton.icon(
            onPressed: () => _showFileRTIDialog(complaint, user),
            icon: const Icon(Icons.description_rounded),
            label: const Text('Initiate New RTI Request'),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildExternalDataTab(complaint, user) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            if (complaint.externalData.isEmpty)
              _emptyState('No research intelligence added yet')
            else
              ...complaint.externalData.map<Widget>((data) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text('RESEARCH DATA', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(data as String, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppTheme.textPrimary)),
                  ],
                ),
              )),
          ],
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: ElevatedButton.icon(
            onPressed: () => _showImportDataDialog(complaint, user),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Import Casework Intelligence'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(complaint, user) {
    final isOwner = complaint.userId == user.id;
    final isAssigned = complaint.assignedVolunteerId == user.id;
    final isAdmin = user.role == 'admin';

    if (!isOwner && !isAssigned && !isAdmin) return const SizedBox.shrink();
    if (complaint.status == 'closed') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (isAssigned || isAdmin) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => _showAddNoteDialog(complaint, user),
                child: const Text('Add Note'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(complaint, user),
                child: const Text('Update Status'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Simplified help methods/dialogs (keeping standard functionality but with new styling)
  void _showStatusUpdateDialog(complaint, user) {
    String? selectedStatus;
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update Casework Stage', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'New Operational Stage'),
              items: AppConstants.statuses.where((s) => s != complaint.status).map((s) => DropdownMenuItem(value: s, child: Text(AppTheme.getStatusLabel(s)))).toList(),
              onChanged: (v) => selectedStatus = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Officer Remarks', hintText: 'Enter internal notes...'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (selectedStatus != null) {
                  context.read<ComplaintProvider>().updateStatus(complaintId: complaint.id, newStatus: selectedStatus!, message: noteController.text.trim(), user: user);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Finalize Stage Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(complaint, user) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Append Internal Note', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            TextFormField(
              controller: noteController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Observe Update', hintText: 'Write update...'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  context.read<ComplaintProvider>().addNote(complaintId: complaint.id, message: noteController.text.trim(), user: user);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Internal Memo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileRTIDialog(complaint, user) {
    final deptController = TextEditingController();
    final requestController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('File Official RTI Request', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            TextFormField(controller: deptController, decoration: const InputDecoration(labelText: 'Target Agency')),
            const SizedBox(height: 16),
            TextFormField(controller: requestController, maxLines: 5, decoration: const InputDecoration(labelText: 'Formal Inquiry Text')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (deptController.text.isNotEmpty && requestController.text.isNotEmpty) {
                  context.read<ComplaintProvider>().fileRTI(complaintId: complaint.id, department: deptController.text.trim(), requestText: requestController.text.trim(), user: user);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Execute File Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDataDialog(complaint, user) {
    final dataController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Import Research Intelligence', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(controller: dataController, maxLines: 8, decoration: const InputDecoration(labelText: 'Paste Intelligence Record')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (dataController.text.trim().isNotEmpty) {
                  context.read<ComplaintProvider>().addExternalData(complaintId: complaint.id, data: dataController.text.trim(), user: user);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Inject Record'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
