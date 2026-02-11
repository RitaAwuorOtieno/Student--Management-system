import 'package:flutter/material.dart';
import '../models/attendance_models.dart';
import '../models/academic_models.dart';
import '../models/student.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedTab = 0;

  // Selected filters
  SchoolClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  Student? _selectedStudent;

  // Sample data
  final List<SchoolClass> _classes = [
    SchoolClass(id: '1', name: 'Grade 1', level: 'Primary', capacity: 40),
    SchoolClass(id: '2', name: 'Grade 2', level: 'Primary', capacity: 40),
    SchoolClass(id: '3', name: 'Grade 3', level: 'Primary', capacity: 40),
    SchoolClass(id: '4', name: 'Grade 4', level: 'Primary', capacity: 40),
    SchoolClass(id: '5', name: 'Grade 5', level: 'Primary', capacity: 40),
    SchoolClass(id: '6', name: 'Grade 6', level: 'Primary', capacity: 40),
    SchoolClass(id: '7', name: 'Grade 7', level: 'Primary', capacity: 40),
    SchoolClass(id: '8', name: 'Grade 8', level: 'Primary', capacity: 40),
    SchoolClass(id: '9', name: 'Form 1', level: 'Secondary', capacity: 45),
    SchoolClass(id: '10', name: 'Form 2', level: 'Secondary', capacity: 45),
    SchoolClass(id: '11', name: 'Form 3', level: 'Secondary', capacity: 45),
    SchoolClass(id: '12', name: 'Form 4', level: 'Secondary', capacity: 45),
  ];

  final List<Student> _students = [
    Student(
        id: 's1',
        admissionNumber: 'ADM001',
        fullName: 'John Doe',
        gender: 'Male',
        classGrade: 'Grade 1',
        parentName: 'Mr. Doe',
        parentPhone: '0712345678',
        relationship: 'Father',
        phone: '',
        address: '',
        city: ''),
    Student(
        id: 's2',
        admissionNumber: 'ADM002',
        fullName: 'Jane Smith',
        gender: 'Female',
        classGrade: 'Grade 1',
        parentName: 'Mrs. Smith',
        parentPhone: '0712345679',
        relationship: 'Mother',
        phone: '',
        address: '',
        city: ''),
    Student(
        id: 's3',
        admissionNumber: 'ADM003',
        fullName: 'Bob Johnson',
        gender: 'Male',
        classGrade: 'Grade 1',
        parentName: 'Mr. Johnson',
        parentPhone: '0712345680',
        relationship: 'Father',
        phone: '',
        address: '',
        city: ''),
    Student(
        id: 's4',
        admissionNumber: 'ADM004',
        fullName: 'Alice Brown',
        gender: 'Female',
        classGrade: 'Grade 1',
        parentName: 'Mrs. Brown',
        parentPhone: '0712345681',
        relationship: 'Mother',
        phone: '',
        address: '',
        city: ''),
    Student(
        id: 's5',
        admissionNumber: 'ADM005',
        fullName: 'Charlie Wilson',
        gender: 'Male',
        classGrade: 'Grade 1',
        parentName: 'Mr. Wilson',
        parentPhone: '0712345682',
        relationship: 'Father',
        phone: '',
        address: '',
        city: ''),
  ];

  // Attendance records (sample)
  final Map<String, Map<String, AttendanceStatus>> _attendanceMap = {};

  // Controller for remarks
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Load sample attendance data for the past week
    final now = DateTime.now();
    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));
      final dateKey = _getDateKey(date);
      _attendanceMap[dateKey] = {};

      for (final student in _students) {
        final random = DateTime.now().millisecond % 10;
        if (random < 7) {
          _attendanceMap[dateKey]![student.id] = AttendanceStatus.present;
        } else if (random < 9) {
          _attendanceMap[dateKey]![student.id] = AttendanceStatus.absent;
        } else {
          _attendanceMap[dateKey]![student.id] = AttendanceStatus.late;
        }
      }
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'Mark Attendance'),
            Tab(text: 'History'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildMarkAttendanceTab(),
          _buildHistoryTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  // ==================== MARK ATTENDANCE TAB ====================
  Widget _buildMarkAttendanceTab() {
    return Column(
      children: [
        // Class and Date Selection
        _buildClassAndDateSelector(),

        // Attendance List
        Expanded(
          child: _selectedClass == null
              ? _buildSelectClassPrompt()
              : _buildAttendanceList(),
        ),
      ],
    );
  }

  Widget _buildClassAndDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  value: _selectedClass,
                  hint: const Text('Select Class'),
                  items: _classes
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.level})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedClass = value),
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedClass != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _markAllPresent,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark All Present'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAttendance,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectClassPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Select a class to mark attendance',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final dateKey = _getDateKey(_selectedDate);
    final classAttendance = _attendanceMap[dateKey] ?? {};

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final status = classAttendance[student.id] ?? AttendanceStatus.present;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.2),
              child:
                  Icon(_getStatusIcon(status), color: _getStatusColor(status)),
            ),
            title: Text(student.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ADM: ${student.admissionNumber}'),
            trailing: _buildStatusDropdown(student.id, status),
            onTap: () => _showStudentDetails(student),
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown(
      String studentId, AttendanceStatus currentStatus) {
    final statuses = AttendanceStatus.values;
    return DropdownButton<AttendanceStatus>(
      value: currentStatus,
      items: statuses
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.toString().split('.').last[0].toUpperCase() +
                    s.toString().split('.').last.substring(1)),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            final dateKey = _getDateKey(_selectedDate);
            _attendanceMap[dateKey] ??= {};
            _attendanceMap[dateKey]![studentId] = value;
          });
        }
      },
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.event_busy;
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  void _markAllPresent() {
    final dateKey = _getDateKey(_selectedDate);
    _attendanceMap[dateKey] = {};
    for (final student in _students) {
      _attendanceMap[dateKey]![student.id] = AttendanceStatus.present;
    }
    setState(() {});
    _showSuccess('All students marked present');
  }

  void _clearAttendance() {
    final dateKey = _getDateKey(_selectedDate);
    _attendanceMap[dateKey] = {};
    setState(() {});
  }

  void _showStudentDetails(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admission: ${student.admissionNumber}'),
            Text('Class: ${student.classGrade}'),
            Text('Gender: ${student.gender}'),
            Text('Parent: ${student.parentName}'),
            Text('Phone: ${student.parentPhone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _remarkController,
              decoration: const InputDecoration(
                labelText: 'Add remark',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Remark saved');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Filters
        _buildHistoryFilters(),
        // History List
        Expanded(
          child: _buildHistoryList(),
        ),
      ],
    );
  }

  Widget _buildHistoryFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  value: _selectedClass,
                  hint: const Text('All Classes'),
                  items: [null, ..._classes]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c?.name ?? 'All Classes'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedClass = value),
                  decoration: const InputDecoration(
                    labelText: 'Filter by Class',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<Student>(
                  value: _selectedStudent,
                  hint: const Text('All Students'),
                  items: [null, ..._students]
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s?.fullName ?? 'All Students'),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedStudent = value),
                  decoration: const InputDecoration(
                    labelText: 'Filter by Student',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text('Apply Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final dateKey = _getDateKey(_selectedDate);
    final classAttendance = _attendanceMap[dateKey] ?? {};

    // Calculate summary
    int present = 0, absent = 0, late = 0, excused = 0;
    for (final status in classAttendance.values) {
      switch (status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        case AttendanceStatus.excused:
          excused++;
          break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Attendance Summary - ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Present', present, Colors.green),
                    _buildSummaryItem('Absent', absent, Colors.red),
                    _buildSummaryItem('Late', late, Colors.orange),
                    _buildSummaryItem('Excused', excused, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Recent Attendance Records',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Recent days
        ...List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: index));
          final key = _getDateKey(date);
          final records = _attendanceMap[key] ?? {};
          final presentCount =
              records.values.where((s) => s == AttendanceStatus.present).length;
          final absentCount =
              records.values.where((s) => s == AttendanceStatus.absent).length;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.date_range, color: Colors.blue),
              ),
              title: Text('${date.day}/${date.month}/${date.year}'),
              subtitle: Text('$presentCount Present, $absentCount Absent'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }

  // ==================== REPORTS TAB ====================
  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generate Attendance Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Report Type Selection
          Card(
            child: Column(
              children: [
                RadioListTile<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: (v) {},
                  title: const Text('Daily Attendance Report'),
                  subtitle: const Text('Attendance for a specific date'),
                ),
                const Divider(),
                RadioListTile<int>(
                  value: 2,
                  groupValue: 1,
                  onChanged: (v) {},
                  title: const Text('Class Attendance Report'),
                  subtitle: const Text(
                      'Attendance summary for a class over a period'),
                ),
                const Divider(),
                RadioListTile<int>(
                  value: 3,
                  groupValue: 1,
                  onChanged: (v) {},
                  title: const Text('Student Attendance Report'),
                  subtitle: const Text('Individual student attendance record'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Report Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Date Range
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Start Date'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('End Date'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Generate Report Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.table_chart),
              label: const Text('Export to Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text('Quick Stats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Overall Stats
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                          'Overall Attendance', '92%', Colors.green),
                      _buildQuickStat('Perfect Days', '15', Colors.blue),
                      _buildQuickStat(
                          'Lowest Attendance', '75%', Colors.orange),
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

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label,
            style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
