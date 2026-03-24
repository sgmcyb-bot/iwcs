import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common_widgets.dart';
import 'complaint_detail_screen.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final complaints = context.watch<ComplaintProvider>();
    final user = auth.currentUser!;
    final myComplaints = complaints.getMyComplaints(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: myComplaints.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No complaints yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'File your first complaint using the + button',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: myComplaints.length,
              itemBuilder: (context, index) {
                final c = myComplaints[index];
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
                      builder: (_) =>
                          ComplaintDetailScreen(complaintId: c.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
