import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common_widgets.dart';
import '../public/complaint_detail_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildOverview(),
          _buildAllComplaints(),
          _buildUserManagement(),
          _buildCityView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'Cases'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group_rounded), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Cities'),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final auth = context.watch<AuthProvider>();
    final complaints = context.watch<ComplaintProvider>();
    final user = auth.currentUser!;
    final stats = complaints.getStats();
    final categoryStats = complaints.getCategoryStats();
    final cityStats = complaints.getCityStats();
    final followUps = complaints.getFollowUpNeeded();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Intelligence,',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Administrator Panel',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                              onPressed: () => auth.logout(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Core Performance Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(label: 'Total Cases', value: '${stats['total'] ?? 0}',
                      icon: Icons.inventory_2_outlined, color: AppTheme.primaryBlue),
                  StatCard(label: 'Open', value: '${stats['open'] ?? 0}',
                      icon: Icons.error_outline_rounded, color: AppTheme.statusOpen),
                  StatCard(label: 'Ongoing', value: '${stats['in_progress'] ?? 0}',
                      icon: Icons.published_with_changes_rounded, color: AppTheme.statusInProgress),
                  StatCard(label: 'Resolved', value: '${stats['resolved'] ?? 0}',
                      icon: Icons.check_circle_outline_rounded, color: AppTheme.statusResolved),
                ],
              ),
            ),
          ),
        ),

        // Urgent Action Required
        if (followUps.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeIn(
              delay: const Duration(milliseconds: 600),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: Colors.red),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alert: Case Activity',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.red),
                          ),
                          Text(
                            '${followUps.length} complaints require immediate attention',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.red.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),

        // Regional Distribution
        _sectionHeader('Regional Distribution'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cityStats.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = cityStats.entries.toList()[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      child: const Icon(Icons.location_city_rounded, color: AppTheme.primaryBlue, size: 20),
                    ),
                    title: Text(entry.key, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value} Cases',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.primaryBlue, fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAllComplaints() {
    final complaints = context.watch<ComplaintProvider>();
    final allComplaints = complaints.getAllComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Intake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: allComplaints.isEmpty
          ? _emptyState('No cases reported yet')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allComplaints.length,
              itemBuilder: (context, index) {
                final c = allComplaints[index];
                return ComplaintCard(
                  id: c.id,
                  title: c.title,
                  category: c.category,
                  city: c.city,
                  status: c.status,
                  createdAt: c.createdAt,
                  priority: c.priority,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComplaintDetailScreen(complaintId: c.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUserManagement() {
    final auth = context.watch<AuthProvider>();
    final allUsers = auth.getAllUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('Member Directory')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final u = allUsers[index];
          final rColor = _roleColor(u.role);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: rColor.withValues(alpha: 0.1),
                child: Text(u.name[0].toUpperCase(),
                    style: TextStyle(color: rColor, fontWeight: FontWeight.w700, fontSize: 18)),
              ),
              title: Text(u.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(u.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(u.role.toUpperCase(), rColor),
                      const SizedBox(width: 8),
                      _badge(u.city, Colors.blueGrey),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'toggle_active') {
                    auth.toggleUserActive(u);
                  } else {
                    auth.updateUserRole(u, v);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'public', child: Text('User: Public')),
                  const PopupMenuItem(value: 'volunteer', child: Text('User: Volunteer')),
                  const PopupMenuItem(value: 'admin', child: Text('User: Admin')),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'toggle_active',
                    child: Text(u.isActive ? 'Suspend Account' : 'Reactivate Account'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildCityView() {
    final complaints = context.watch<ComplaintProvider>();
    final cityStats = complaints.getCityStats();

    return Scaffold(
      appBar: AppBar(title: const Text('Infrastructure Map')),
      body: cityStats.isEmpty
          ? _emptyState('No geographic data')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cityStats.length,
              itemBuilder: (context, index) {
                final entry = cityStats.entries.toList()[index];
                final cityComplaints = complaints.getComplaintsByCity(entry.key);
                final open = cityComplaints.where((c) => c.status == 'open').length;
                final resolved = cityComplaints.where((c) => c.status == 'resolved').length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade50),
                  ),
                  child: ExpansionTile(
                    title: Text(entry.key, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    subtitle: Text('${entry.value} reports recorded', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    leading: const Icon(Icons.corporate_fare_rounded, color: AppTheme.primaryBlue),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _cityStatBlock('OPEN', '$open', AppTheme.statusOpen),
                                _cityStatBlock('RESOLVED', '$resolved', AppTheme.statusResolved),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                complaints.setFilters(city: entry.key);
                                setState(() => _currentTab = 1);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                backgroundColor: Colors.grey.shade50,
                                foregroundColor: AppTheme.primaryBlue,
                                elevation: 0,
                              ),
                              child: const Text('View Detailed City Report'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _cityStatBlock(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400)),
      ],
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return Colors.indigo;
      case 'volunteer': return Colors.teal;
      default: return AppTheme.primaryBlue;
    }
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final complaints = context.read<ComplaintProvider>();
    String? city = complaints.cityFilter;
    String? status = complaints.statusFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Refine Search', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: city,
              decoration: const InputDecoration(labelText: 'Focus City'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Global View')),
                ...AppConstants.cities.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (v) => city = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'Casework Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Stages')),
                ...AppConstants.statuses.map((s) => DropdownMenuItem(value: s, child: Text(AppTheme.getStatusLabel(s)))),
              ],
              onChanged: (v) => status = v,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                complaints.setFilters(city: city, status: status);
                Navigator.pop(ctx);
              },
              child: const Text('Apply Changes'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                complaints.clearFilters();
                Navigator.pop(ctx);
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
