import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common_widgets.dart';
import 'file_complaint_screen.dart';
import 'complaint_detail_screen.dart';
import 'my_complaints_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    final screens = [
      _buildDashboard(context),
      const MyComplaintsScreen(),
      Container(), // FAB Placeholder
      _buildNotificationsScreen(context),
      _buildProfileScreen(context),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FileComplaintScreen()),
        ),
        tooltip: 'New Complaint',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex == 2 ? 0 : _currentIndex, // adjust for hidden FAB index
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx >= 2 ? idx + 1 : idx;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Cases'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final complaints = context.watch<ComplaintProvider>();
    final user = auth.currentUser!;
    final stats = complaints.getStats();

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
                                'Good Morning,',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user.name.split(' ')[0],
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 26,
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

        // Quick Stats Summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _statHeader('Open Cases', '${stats['open'] ?? 0}', AppTheme.statusOpen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statHeader('Resolved', '${stats['resolved'] ?? 0}', AppTheme.statusResolved),
                ),
              ],
            ),
          ),
        ),

        // All Stats Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  label: 'Total Filed',
                  value: '${stats['total'] ?? 0}',
                  icon: Icons.folder_copy_outlined,
                  color: AppTheme.primaryBlue,
                ),
                StatCard(
                  label: 'In Progress',
                  value: '${stats['in_progress'] ?? 0}',
                  icon: Icons.sync_rounded,
                  color: AppTheme.statusInProgress,
                ),
              ],
            ),
          ),
        ),

        // Action Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Text(
                  'Your Recent Cases',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        // Complaint List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final myComplaints = complaints.getMyComplaints(user.id);
              if (myComplaints.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('No complaints found', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                );
              }
              if (index >= myComplaints.length) return null;
              final c = myComplaints[index];

              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * index),
                child: ComplaintCard(
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
                ),
              );
            },
            childCount: complaints.getMyComplaints(user.id).length.clamp(0, 5),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _statHeader(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildNotificationsScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No new alerts', style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(user.name, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _profileTile(Icons.alternate_email_rounded, 'Email Address', user.email),
          _profileTile(Icons.location_on_outlined, 'Assigned City', user.city),
          _profileTile(Icons.phone_outlined, 'Contact Number', user.phone.isEmpty ? 'Not Provided' : user.phone),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
