import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'student_page.dart';
import 'fees_page.dart';
import 'course_outline_page.dart';
import 'dart:async';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _auth = AuthService();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(null);
        }
      } else {
        // Load user data and subscribe to changes
        await Provider.of<UserProvider>(context, listen: false)
            .loadUser(user.uid);
        _userSubscription = Provider.of<UserProvider>(context, listen: false)
            .userStream(user.uid)
            .listen((AppUser? appUser) {
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Show loading while checking auth state
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in, show login page
        if (userProvider.currentUser == null) {
          return const LoginPage();
        }

        // Get the appropriate dashboard based on role
        final user = userProvider.currentUser!;
        return _getDashboardForRole(user.role);
      },
    );
  }

  Widget _getDashboardForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.teacher:
        return const TeacherDashboard();
      case UserRole.accountant:
        return const AccountantDashboard();
      case UserRole.student:
        return const StudentDashboard();
      case UserRole.parent:
        return const ParentDashboard();
    }
  }
}

// Admin Dashboard - Full Access
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${user.fullName}'),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildDashboardGrid(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final items = [
      {
        'icon': Icons.school,
        'title': 'Students',
        'color': Colors.blue,
        'page': const StudentPage()
      },
      {
        'icon': Icons.payment,
        'title': 'Fees',
        'color': Colors.green,
        'page': const FeesPage()
      },
      {
        'icon': Icons.menu_book,
        'title': 'Courses',
        'color': Colors.orange,
        'page': const CourseOutlinePage()
      },
      {
        'icon': Icons.people,
        'title': 'Teachers',
        'color': Colors.purple,
        'page': const PlaceholderPage(title: 'Teachers Management')
      },
      {
        'icon': Icons.account_balance,
        'title': 'Accountants',
        'color': Colors.teal,
        'page': const PlaceholderPage(title: 'Accountants Management')
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Reports',
        'color': Colors.indigo,
        'page': const PlaceholderPage(title: 'Reports')
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'color': Colors.grey,
        'page': const PlaceholderPage(title: 'Settings')
      },
      {
        'icon': Icons.person,
        'title': 'Profile',
        'color': Colors.cyan,
        'page': const PlaceholderPage(title: 'My Profile')
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildDashboardCard(
            context,
            item['icon'] as IconData,
            item['title'] as String,
            item['color'] as Color,
            item['page'] as Widget,
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, IconData icon, String title,
      Color color, Widget page) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade700),
            accountName: Text(user.fullName),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.fullName
                    .split(' ')
                    .map((e) => e[0])
                    .take(2)
                    .join('')
                    .toUpperCase(),
                style: TextStyle(
                    color: Colors.red.shade700, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}

// Teacher Dashboard
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard - ${user.fullName}'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user.fullName),
            const SizedBox(height: 24),
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                      Icons.school, 'My Students', Colors.blue),
                  _buildQuickActionCard(
                      Icons.grading, 'Add Grades', Colors.green),
                  _buildQuickActionCard(
                      Icons.calendar_today, 'Attendance', Colors.orange),
                  _buildQuickActionCard(
                      Icons.message, 'Messages', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Accountant Dashboard
class AccountantDashboard extends StatelessWidget {
  const AccountantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accountant Dashboard - ${user.fullName}'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user.fullName, Colors.green),
            const SizedBox(height: 24),
            const Text('Finance Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                      Icons.payment, 'Process Payments', Colors.green),
                  _buildQuickActionCard(
                      Icons.receipt, 'Fee Records', Colors.blue),
                  _buildQuickActionCard(
                      Icons.account_balance_wallet, 'Expenses', Colors.orange),
                  _buildQuickActionCard(
                      Icons.bar_chart, 'Reports', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Student Dashboard
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Portal - ${user.fullName}'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle('My Information'),
                  _buildInfoTile(Icons.school, 'Class/Grade', 'Grade 8'),
                  _buildInfoTile(Icons.numbers, 'Admission Number', 'ADM001'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Links'),
                  _buildLinkTile(Icons.grade, 'My Grades'),
                  _buildLinkTile(Icons.payment, 'My Fees'),
                  _buildLinkTile(Icons.calendar_today, 'Attendance'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              user.fullName
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join('')
                  .toUpperCase(),
              style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                user.email,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

// Parent Dashboard
class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Portal - ${user.fullName}'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.purple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.fullName
                          .split(' ')
                          .map((e) => e[0])
                          .take(2)
                          .join('')
                          .toUpperCase(),
                      style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Parent/Guardian',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle('My Children'),
                  _buildChildCard('John Doe', 'Grade 8', Icons.person),
                  _buildChildCard('Jane Doe', 'Grade 6', Icons.person),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Links'),
                  _buildLinkTile(Icons.grade, 'View Grades'),
                  _buildLinkTile(Icons.payment, 'View Fees'),
                  _buildLinkTile(Icons.message, 'Contact Teachers'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChildCard(String name, String grade, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(name),
        subtitle: Text(grade),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

// Placeholder page for other features
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
