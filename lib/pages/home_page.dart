import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'student_page.dart';
import 'fees_page.dart';
import 'academic_page.dart';
import 'attendance_page.dart';
import 'exams_page.dart';
import 'reports_page.dart';
import 'role_dashboards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _getPages(user);
    final destinations = _getDestinations(user.role);

    // Ensure index is valid when switching roles
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: destinations,
      ),
      floatingActionButton: _buildFAB(user),
    );
  }

  List<Widget> _getPages(AppUser user) {
    final homeTab = _buildHomeTab(user);

    switch (user.role) {
      case UserRole.teacher:
        return [
          homeTab,
          const StudentPage(),
          const AttendancePage(),
          const ExamsPage(),
        ];
      case UserRole.parent:
        return [
          homeTab,
          const FeesPage(),
          const AcademicPage(),
          const AttendancePage(),
        ];
      case UserRole.accountant:
        return [
          homeTab,
          const FeesPage(),
          const ReportsPage(),
          const PlaceholderPage(title: 'Expenses'),
        ];
      case UserRole.student:
        return [
          homeTab,
          const AcademicPage(),
          const AttendancePage(),
          const FeesPage(),
        ];
      case UserRole.admin:
      default:
        return [
          homeTab,
          const StudentPage(),
          const FeesPage(),
          const ReportsPage(),
        ];
    }
  }

  List<NavigationDestination> _getDestinations(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Exams'),
        ];
      case UserRole.parent:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.grade), label: 'Academics'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Attendance'),
        ];
      case UserRole.accountant:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Expenses'),
        ];
      case UserRole.student:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Academics'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Fees'),
        ];
      case UserRole.admin:
      default:
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ];
    }
  }

  Widget _buildHomeTab(AppUser user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.school,
              size: 32,
              color: Colors.white,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome, ${user.fullName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRoleColor(user.role),
                    _getRoleColor(user.role).withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildQuickStats(user),
              const SizedBox(height: 24),
              _buildQuickActions(user),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(AppUser user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            label: 'Students',
            value: '1,234',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            label: 'Teachers',
            value: '56',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.payment,
            label: 'Fees',
            value: '98%',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppUser user) {
    final actions = _getQuickActions(user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () => _navigateToPage(action['page'] as Widget),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getQuickActions(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          {
            'icon': Icons.dashboard,
            'title': 'Dashboard',
            'color': Colors.red,
            'page': const AdminDashboard()
          },
          {
            'icon': Icons.people,
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
            'icon': Icons.check_circle,
            'title': 'Attendance',
            'color': Colors.orange,
            'page': const AttendancePage()
          },
          {
            'icon': Icons.assignment,
            'title': 'Exams',
            'color': Colors.purple,
            'page': const ExamsPage()
          },
          {
            'icon': Icons.grade,
            'title': 'Academic',
            'color': Colors.teal,
            'page': const AcademicPage()
          },
          {
            'icon': Icons.bar_chart,
            'title': 'Reports',
            'color': Colors.indigo,
            'page': const ReportsPage()
          },
          {
            'icon': Icons.person_add,
            'title': 'Teachers',
            'color': Colors.cyan,
            'page': const PlaceholderPage(title: 'Teachers')
          },
          {
            'icon': Icons.settings,
            'title': 'Settings',
            'color': Colors.grey,
            'page': const PlaceholderPage(title: 'Settings')
          },
        ];
      case UserRole.teacher:
        return [
          {
            'icon': Icons.people,
            'title': 'Students',
            'color': Colors.blue,
            'page': const StudentPage()
          },
          {
            'icon': Icons.check_circle,
            'title': 'Attendance',
            'color': Colors.orange,
            'page': const AttendancePage()
          },
          {
            'icon': Icons.assignment,
            'title': 'Exams',
            'color': Colors.purple,
            'page': const ExamsPage()
          },
          {
            'icon': Icons.grade,
            'title': 'Grades',
            'color': Colors.teal,
            'page': const AcademicPage()
          },
        ];
      case UserRole.accountant:
        return [
          {
            'icon': Icons.payment,
            'title': 'Fees',
            'color': Colors.green,
            'page': const FeesPage()
          },
          {
            'icon': Icons.receipt,
            'title': 'Payments',
            'color': Colors.blue,
            'page': const FeesPage()
          },
          {
            'icon': Icons.bar_chart,
            'title': 'Reports',
            'color': Colors.indigo,
            'page': const ReportsPage()
          },
          {
            'icon': Icons.account_balance_wallet,
            'title': 'Expenses',
            'color': Colors.orange,
            'page': const PlaceholderPage(title: 'Expenses')
          },
        ];
      case UserRole.student:
      case UserRole.parent:
        return [
          {
            'icon': Icons.grade,
            'title': 'Grades',
            'color': Colors.purple,
            'page': const AcademicPage()
          },
          {
            'icon': Icons.payment,
            'title': 'Fees',
            'color': Colors.green,
            'page': const FeesPage()
          },
          {
            'icon': Icons.check_circle,
            'title': 'Attendance',
            'color': Colors.orange,
            'page': const AttendancePage()
          },
          {
            'icon': Icons.assignment,
            'title': 'Exams',
            'color': Colors.red,
            'page': const ExamsPage()
          },
        ];
    }
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.payment,
                title: 'Fee Payment Received',
                subtitle: 'KES 15,000 from John Doe',
                time: '2 hours ago',
                color: Colors.green,
              ),
              const Divider(),
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'New Student Registered',
                subtitle: 'Jane Smith - Grade 8',
                time: '5 hours ago',
                color: Colors.blue,
              ),
              const Divider(),
              _buildActivityItem(
                icon: Icons.assignment,
                title: 'Exam Results Uploaded',
                subtitle: 'End Term Exams - Form 1',
                time: '1 day ago',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(AppUser user) {
    return const StudentPage();
  }

  Widget _buildFeesTab(AppUser user) {
    return const FeesPage();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAB(AppUser user) {
    return FloatingActionButton(
      heroTag: 'home_fab',
      onPressed: () {
        switch (user.role) {
          case UserRole.admin:
          case UserRole.teacher:
            _showQuickAddMenu();
            break;
          case UserRole.accountant:
            _navigateToPage(const FeesPage());
            break;
          case UserRole.student:
          case UserRole.parent:
            _navigateToPage(const FeesPage());
            break;
        }
      },
      backgroundColor: _getRoleColor(user.role),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add Student',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPage(const StudentPage());
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.payment,
                  label: 'Record Payment',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPage(const FeesPage());
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.assignment,
                  label: 'Add Grade',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPage(const ExamsPage());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red.shade700;
      case UserRole.teacher:
        return Colors.blue.shade700;
      case UserRole.accountant:
        return Colors.green.shade700;
      case UserRole.student:
        return Colors.orange.shade700;
      case UserRole.parent:
        return Colors.purple.shade700;
    }
  }
}

// Placeholder page for features not yet implemented
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
              'Coming Soon',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
