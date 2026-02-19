import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../provider/user_provider.dart';
import 'student_page.dart';
import 'fees_page.dart';
import 'attendance_page.dart';
import 'exams_page.dart';
import 'reports_page.dart';
import 'academic_page.dart';

/// =========================================================
/// ================= TEACHER DASHBOARD =====================
/// =========================================================
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TeacherHomeTab(),
    StudentPage(),
    AttendancePage(),
    ExamsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Assignments'),
        ],
      ),
    );
  }
}

class TeacherHomeTab extends StatelessWidget {
  const TeacherHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.fullName ?? 'Teacher'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search student by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(context, 'Take Attendance',
                    Icons.check_circle_outline, Colors.orange, const AttendancePage()),
                _buildActionCard(context, 'Give Assignment',
                    Icons.assignment_outlined, Colors.purple, const ExamsPage()),
                _buildActionCard(context, 'View Students',
                    Icons.people_outline, Colors.blue, const StudentPage()),
                _buildActionCard(context, 'Grading',
                    Icons.grade_outlined, Colors.teal, const AcademicPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title,
      IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/// =========================================================
/// ================= PARENT DASHBOARD ======================
/// =========================================================
class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ParentHomeTab(),
    FeesPage(),
    AcademicPage(),
    AttendancePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.grade), label: 'Academics'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Attendance'),
        ],
      ),
    );
  }
}

class ParentHomeTab extends StatelessWidget {
  const ParentHomeTab({super.key});

  /// ================= STK PUSH =================
  Future<void> _initiateStkPush(
      BuildContext context, String phone, String amount) async {
    String formattedPhone = phone.trim();

    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254${formattedPhone.substring(1)}';
    }

    if (!formattedPhone.startsWith('2547') || formattedPhone.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid Safaricom number')),
      );
      return;
    }

    if (int.tryParse(amount) == null || int.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      const String baseUrl = 'http://10.0.2.2:3000';

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': formattedPhone,
          'amount': int.parse(amount),
          'accountReference': 'SchoolFees',
          'transactionDesc': 'Fee Payment'
        }),
      );

      if (context.mounted) {
        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Check phone for PIN')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Payment failed')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error')),
        );
      }
    }
  }

  void _showPaymentDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final amountController =
        TextEditingController(text: "23000");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pay School Fees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Safaricom Number (07XXXXXXXX)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final phone = phoneController.text;
              final amount = amountController.text;
              Navigator.pop(context);
              _initiateStkPush(context, phone, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Portal - ${user?.fullName ?? ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Total Fee Due',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('KES 23,000',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay via M-Pesa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AcademicPage(), // Grades
    const AttendancePage(),
    const FeesPage(), // View only
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school), label: 'Academics'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Fee Status'),
        ],
      ),
    );
  }
}

// --- ADMIN DASHBOARD (Reusing existing HomePage logic) ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This is essentially the original HomePage implementation for Admins
    // You can copy the original _buildHomeTab etc here if you want to keep Admin separate
    // For brevity, I'll return a Scaffold with the Admin features
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminCard('Manage Students', Icons.people, Colors.blue, const StudentPage()),
          _buildAdminCard('Manage Fees', Icons.payment, Colors.green, const FeesPage()),
          _buildAdminCard('Reports', Icons.bar_chart, Colors.indigo, const ReportsPage()),
          _buildAdminCard('Settings', Icons.settings, Colors.grey, const Scaffold(body: Center(child: Text('Settings')))),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        color: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}