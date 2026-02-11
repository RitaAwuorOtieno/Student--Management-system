import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedAcademicYear = '2024';
  String _selectedTerm = 'Term 1';
  final List<String> _academicYears = ['2023', '2024', '2025'];
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3'];

  // Sample data for reports
  final int _totalStudents = 450;
  final int _totalTeachers = 32;
  final int _totalClasses = 24;
  final double _totalFeesCollected = 12500000;
  final double _totalFeesPending = 3200000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.indigo.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Students'),
            Tab(text: 'Academic'),
            Tab(text: 'Finance'),
            Tab(text: 'Attendance'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(),
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(),
            tooltip: 'Print Report',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStudentsTab(),
          _buildAcademicTab(),
          _buildFinanceTab(),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  // ==================== OVERVIEW TAB ====================
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAcademicYear,
                    items: _academicYears
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedAcademicYear = value!),
                    decoration:
                        const InputDecoration(labelText: 'Academic Year'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTerm,
                    items: _terms
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTerm = value!),
                    decoration: const InputDecoration(labelText: 'Term'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Quick Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(Icons.people, 'Total Students',
                  _totalStudents.toString(), Colors.blue),
              _buildStatCard(Icons.school, 'Total Teachers',
                  _totalTeachers.toString(), Colors.green),
              _buildStatCard(Icons.class_, 'Total Classes',
                  _totalClasses.toString(), Colors.orange),
              _buildStatCard(
                  Icons.attach_money,
                  'Fees Collected',
                  'KSH ${(_totalFeesCollected / 1000000).toStringAsFixed(1)}M',
                  Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Performance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSimpleBarChart(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Grade 1-4', Colors.green),
                      _buildLegendItem('Grade 5-8', Colors.blue),
                      _buildLegendItem('Form 1-2', Colors.orange),
                      _buildLegendItem('Form 3-4', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6)
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(35, 'P1', Colors.green),
          _buildBar(42, 'P2', Colors.blue),
          _buildBar(38, 'P3', Colors.orange),
          _buildBar(45, 'P4', Colors.purple),
          _buildBar(40, 'P5', Colors.red),
          _buildBar(32, 'P6', Colors.teal),
          _buildBar(28, 'P7', Colors.indigo),
          _buildBar(22, 'P8', Colors.pink),
          _buildBar(38, 'S1', Colors.cyan),
          _buildBar(40, 'S2', Colors.amber),
          _buildBar(35, 'S3', Colors.lime),
          _buildBar(45, 'S4', Colors.brown),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  // ==================== STUDENTS TAB ====================
  Widget _buildStudentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildMetricCard('Total Enrollment',
                      _totalStudents.toString(), Icons.people, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard(
                      'New Admissions', '45', Icons.person_add, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildMetricCard(
                      'Active Students', '420', Icons.school, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard(
                      'Inactive', '30', Icons.exit_to_app, Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Gender Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPieSection(52, 'Male', Colors.blue),
                  _buildPieSection(48, 'Female', Colors.pink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Students by Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildLevelDistribution(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieSection(double percentage, String label, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text('${percentage.toInt()}%',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLevelDistribution() {
    final levels = [
      {'name': 'Primary 1-4', 'count': 170, 'color': Colors.green},
      {'name': 'Primary 5-8', 'count': 137, 'color': Colors.blue},
      {'name': 'Secondary 1-2', 'count': 78, 'color': Colors.orange},
      {'name': 'Secondary 3-4', 'count': 80, 'color': Colors.red},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: levels.map((l) {
            final percentage = (l['count'] as int) / _totalStudents * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l['name'] as String),
                      Text('${l['count']} (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(l['color'] as Color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==================== ACADEMIC TAB ====================
  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPerformanceMetric('Average Score', '72.3%',
                      Icons.trending_up, Colors.green),
                  _buildPerformanceMetric(
                      'Pass Rate', '94.2%', Icons.check_circle, Colors.blue),
                  _buildPerformanceMetric(
                      'Top Scorer', '98.5%', Icons.emoji_events, Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Subject Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSubjectPerformanceTable(),
          const SizedBox(height: 24),
          const Text('Top 5 Students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTopPerformersList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSubjectPerformanceTable() {
    final subjects = [
      {'subject': 'Mathematics', 'avg': 68.5, 'pass': 89.2},
      {'subject': 'English', 'avg': 75.2, 'pass': 94.5},
      {'subject': 'Kiswahili', 'avg': 72.8, 'pass': 91.8},
      {'subject': 'Science', 'avg': 65.3, 'pass': 85.4},
      {'subject': 'Social Studies', 'avg': 78.9, 'pass': 96.1},
      {'subject': 'Religious Ed.', 'avg': 82.4, 'pass': 98.2},
    ];

    return Card(
      elevation: 2,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Avg'), numeric: true),
          DataColumn(label: Text('Pass %'), numeric: true),
        ],
        rows: subjects
            .map((s) => DataRow(cells: [
                  DataCell(Text(s['subject'] as String)),
                  DataCell(Text('${s['avg']}%')),
                  DataCell(Text('${s['pass']}%')),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildTopPerformersList() {
    final topStudents = [
      {'name': 'Alice Johnson', 'avg': 98.5},
      {'name': 'Bob Smith', 'avg': 97.2},
      {'name': 'Charlie Brown', 'avg': 96.8},
      {'name': 'Diana Prince', 'avg': 95.5},
      {'name': 'Ethan Hunt', 'avg': 94.8},
    ];

    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topStudents.length,
        itemBuilder: (context, index) {
          final student = topStudents[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index == 0 ? Colors.amber : Colors.blue.shade100,
              child: index == 0
                  ? const Icon(Icons.emoji_events, color: Colors.amber)
                  : Text('${index + 1}'),
            ),
            title: Text(student['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              '${student['avg']}%',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          );
        },
      ),
    );
  }

  // ==================== FINANCE TAB ====================
  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildFinancialMetric(
                              'Total Fees', 'KSH 15.7M', Colors.blue)),
                      Expanded(
                          child: _buildFinancialMetric(
                              'Collected', 'KSH 12.5M', Colors.green)),
                      Expanded(
                          child: _buildFinancialMetric(
                              'Pending', 'KSH 3.2M', Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalFeesCollected /
                          (_totalFeesCollected + _totalFeesPending),
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collection Rate: ${(_totalFeesCollected / (_totalFeesCollected + _totalFeesPending) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Payments by Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPaymentMethodRow('M-Pesa', 45, 5600000, Colors.green),
                  _buildPaymentMethodRow('Cash', 30, 3750000, Colors.blue),
                  _buildPaymentMethodRow(
                      'Bank Transfer', 20, 2500000, Colors.orange),
                  _buildPaymentMethodRow('Cheque', 5, 625000, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Top Defaulters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.warning, color: Colors.white, size: 20),
                  ),
                  title: Text('Student ${index + 1}'),
                  subtitle: Text('ADM-2024-00${index + 1}'),
                  trailing: Text(
                    'KSH ${(50000 - (index * 5000)).toString()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildPaymentMethodRow(
      String method, int percentage, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(method == 'M-Pesa' ? Icons.phone_android : Icons.account_balance,
              color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(method),
                    Text('$percentage%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ATTENDANCE TAB ====================
  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttendanceMetric(
                      'Avg Attendance', '92.5%', Icons.people, Colors.green),
                  _buildAttendanceMetric('Present Today', '435/450',
                      Icons.check_circle, Colors.blue),
                  _buildAttendanceMetric(
                      'Absent Today', '15', Icons.cancel, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Attendance by Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                final data = [
                  {'name': 'Primary 1-4', 'percent': 94},
                  {'name': 'Primary 5-8', 'percent': 91},
                  {'name': 'Secondary 1-2', 'percent': 89},
                  {'name': 'Secondary 3-4', 'percent': 87},
                ];
                final percent = data[index]['percent'] as int;
                return ListTile(
                  title: Text(data[index]['name'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: percent >= 90
                              ? Colors.green
                              : percent >= 85
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        percent >= 90
                            ? Icons.sentiment_satisfied
                            : percent >= 85
                                ? Icons.sentiment_neutral
                                : Icons.sentiment_dissatisfied,
                        color: percent >= 90
                            ? Colors.green
                            : percent >= 85
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Weekly Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDayIndicator('Mon', 94, true),
                  _buildDayIndicator('Tue', 92, true),
                  _buildDayIndicator('Wed', 89, false),
                  _buildDayIndicator('Thu', 95, true),
                  _buildDayIndicator('Fri', 91, true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDayIndicator(String day, int percentage, bool attended) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: attended ? Colors.green.shade100 : Colors.red.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: attended ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: attended ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _showSuccess('PDF export started');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Excel export started');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _printReport() {
    _showSuccess('Printing report...');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
