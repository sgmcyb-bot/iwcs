import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common_widgets.dart';
import '../public/complaint_detail_screen.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final complaints = context.watch<ComplaintProvider>();
    final user = auth.currentUser!;
    final stats = complaints.getStats();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Volunteer Panel',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: () => auth.logout(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Monitoring ${user.city}',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Volunteer Focus Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _miniStat('Assigned', '${stats['open'] ?? 0}', AppTheme.statusOpen, Icons.assignment_late_outlined),
                  _miniStat('Ongoing', '${stats['in_progress'] ?? 0}', AppTheme.statusInProgress, Icons.sync_rounded),
                  _miniStat('Resolved', '${stats['resolved'] ?? 0}', AppTheme.statusResolved, Icons.check_circle_outline_rounded),
                ],
              ),
            ),
          ),

          // Follow-up Section
          _sectionHeader('Priority Action Items'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final assigned = complaints.getComplaintsByStatus('open')
                    .where((c) => c.assignedVolunteerId == user.id || c.city == user.city).toList();
                
                if (assigned.isEmpty) {
                  return _emptyState('No pending cases in your city');
                }
                
                if (index >= assigned.length) return null;
                final c = assigned[index];

                return FadeInRight(
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
              childCount: complaints.getComplaintsByStatus('open')
                  .where((c) => c.assignedVolunteerId == user.id || c.city == user.city).length.clamp(0, 10),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
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

  Widget _miniStat(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
