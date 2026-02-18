import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../models/academic_models.dart';
import '../models/student.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  int _selectedTab = 0;

  // Sample data
  final List<Exam> _exams = [];
  final List<Result> _results = [];
  final List<ExamType> _examTypes = ExamType.values;
  final List<String> _academicYears = ['2024', '2025'];
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3'];

  // Selected filters
  SchoolClass? _selectedClass;
  ExamType _selectedExamType = ExamType.CAT;
  String _selectedAcademicYear = '2024';
  String _selectedTerm = 'Term 1';

  // Sample subjects
  final List<Subject> _subjects = [
    Subject(id: '1', name: 'Mathematics', code: 'MATH'),
    Subject(id: '2', name: 'English', code: 'ENG'),
    Subject(id: '3', name: 'Kiswahili', code: 'KIS'),
    Subject(id: '4', name: 'Science', code: 'SCI'),
    Subject(id: '5', name: 'Social Studies', code: 'SST'),
    Subject(id: '6', name: 'Religious Education', code: 'RE'),
  ];

  // Sample students
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

  // Sample classes
  final List<SchoolClass> _classes = [
    SchoolClass(id: '1', name: 'Grade 1', level: 'Primary'),
    SchoolClass(id: '2', name: 'Grade 2', level: 'Primary'),
    SchoolClass(id: '3', name: 'Grade 3', level: 'Primary'),
    SchoolClass(id: '4', name: 'Grade 4', level: 'Primary'),
    SchoolClass(id: '5', name: 'Grade 5', level: 'Primary'),
    SchoolClass(id: '6', name: 'Grade 6', level: 'Primary'),
    SchoolClass(id: '7', name: 'Grade 7', level: 'Primary'),
    SchoolClass(id: '8', name: 'Grade 8', level: 'Primary'),
    SchoolClass(id: '9', name: 'Form 1', level: 'Secondary'),
    SchoolClass(id: '10', name: 'Form 2', level: 'Secondary'),
    SchoolClass(id: '11', name: 'Form 3', level: 'Secondary'),
    SchoolClass(id: '12', name: 'Form 4', level: 'Secondary'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Load sample exams
    setState(() {
      _exams.addAll([
        Exam(
            id: 'e1',
            name: 'Mathematics CAT 1',
            classId: '1',
            subjectId: '1',
            type: ExamType.CAT,
            date: DateTime.now(),
            maxMarks: 50,
            academicYear: '2024',
            term: 'Term 1'),
        Exam(
            id: 'e2',
            name: 'English CAT 1',
            classId: '1',
            subjectId: '2',
            type: ExamType.CAT,
            date: DateTime.now().subtract(const Duration(days: 1)),
            maxMarks: 50,
            academicYear: '2024',
            term: 'Term 1'),
        Exam(
            id: 'e3',
            name: 'Mathematics Midterm',
            classId: '1',
            subjectId: '1',
            type: ExamType.midterm,
            date: DateTime.now().subtract(const Duration(days: 7)),
            maxMarks: 100,
            academicYear: '2024',
            term: 'Term 1'),
        Exam(
            id: 'e4',
            name: 'End Term Exam',
            classId: '1',
            subjectId: '1',
            type: ExamType.endTerm,
            date: DateTime.now().subtract(const Duration(days: 30)),
            maxMarks: 100,
            academicYear: '2023',
            term: 'Term 3'),
      ]);

      // Load sample results
      for (final exam in _exams) {
        for (final student in _students) {
          final random = DateTime.now().millisecond % 100;
          _results.add(Result(
            id: 'r_${exam.id}_${student.id}',
            examId: exam.id,
            studentId: student.id,
            marksObtained: random.toDouble(),
            gradedBy: 'Teacher',
            gradedAt: DateTime.now(),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exams & Results'),
          backgroundColor: Colors.blue.shade700,
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: const [
              Tab(text: 'Exams'),
              Tab(text: 'Enter Marks'),
              Tab(text: 'Results'),
              Tab(text: 'Report Cards'),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedTab,
          children: [
            _buildExamsTab(),
            _buildEnterMarksTab(),
            _buildResultsTab(),
            _buildReportCardsTab(),
          ],
        ),
        floatingActionButton: _selectedTab == 0
            ? FloatingActionButton.extended(
                onPressed: () => _showCreateExamDialog(),
                label: const Text('Create Exam'),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.blue.shade700,
              )
            : null,
      ),
    );
  }

  // ==================== EXAMS TAB ====================
  Widget _buildExamsTab() {
    return Column(
      children: [
        // Filters
        _buildExamFilters(),
        // Exams List
        Expanded(
          child: _exams.isEmpty
              ? _buildEmptyExamsState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final subject = _subjects.firstWhere(
                        (s) => s.id == exam.subjectId,
                        orElse: () =>
                            Subject(id: '', name: 'Unknown', code: ''));
                    final schoolClass = _classes.firstWhere(
                        (c) => c.id == exam.classId,
                        orElse: () =>
                            SchoolClass(id: '', name: 'Unknown', level: ''));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getExamTypeColor(exam.type).withOpacity(0.2),
                          child: Icon(_getExamTypeIcon(exam.type),
                              color: _getExamTypeColor(exam.type)),
                        ),
                        title: Text(exam.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${subject.name} | ${schoolClass.name}'),
                            Text(
                                '${exam.date.day}/${exam.date.month}/${exam.date.year} | Max: ${exam.maxMarks}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') _deleteExam(exam.id);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                        onTap: () => _showExamDetails(exam),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExamFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
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
                labelText: 'Class',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedAcademicYear,
              items: _academicYears
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedAcademicYear = value!),
              decoration: const InputDecoration(
                labelText: 'Year',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExamsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No exams found', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showCreateExamDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create First Exam'),
          ),
        ],
      ),
    );
  }

  void _showCreateExamDialog() {
    final _nameController = TextEditingController();
    String _selectedSubject = '';
    String _selectedClassId = '';
    int _maxMarks = 50;
    ExamType _examType = ExamType.CAT;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Exam'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Exam Name *',
                    prefixIcon: Icon(Icons.assignment)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSubject.isEmpty ? null : _selectedSubject,
                hint: const Text('Select Subject'),
                items: _subjects
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => _selectedSubject = value!,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedClassId.isEmpty ? null : _selectedClassId,
                hint: const Text('Select Class'),
                items: _classes
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => _selectedClassId = value!,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExamType>(
                value: _examType,
                items: _examTypes
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => _examType = value!,
                decoration: const InputDecoration(labelText: 'Exam Type'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Max Marks: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(
                      () => _maxMarks = (_maxMarks > 10) ? _maxMarks - 10 : 10),
                ),
                Text('$_maxMarks',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _maxMarks += 10),
                ),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _selectedSubject.isEmpty ||
                  _selectedClassId.isEmpty) {
                _showError('Please fill all required fields');
                return;
              }
              setState(() {
                _exams.add(Exam(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  classId: _selectedClassId,
                  subjectId: _selectedSubject,
                  type: _examType,
                  date: DateTime.now(),
                  maxMarks: _maxMarks,
                  academicYear: _selectedAcademicYear,
                  term: _selectedTerm,
                ));
              });
              Navigator.pop(context);
              _showSuccess('Exam created successfully');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _deleteExam(String examId) {
    setState(() => _exams.removeWhere((e) => e.id == examId));
    _showSuccess('Exam deleted');
  }

  void _showExamDetails(Exam exam) {
    // Show exam details
  }

  // ==================== ENTER MARKS TAB ====================
  Widget _buildEnterMarksTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Exam>(
                      hint: const Text('Select Exam'),
                      items: _exams
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Exam',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<SchoolClass>(
                      value: _selectedClass,
                      hint: const Text('Select Class'),
                      items: _classes
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedClass = value),
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Marks Entry List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(student.initials),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('ADM: ${student.admissionNumber}'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Marks',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Save Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Save Marks'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== RESULTS TAB ====================
  Widget _buildResultsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  value: _selectedClass,
                  hint: const Text('Select Class'),
                  items: [null, ..._classes]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c?.name ?? 'All Classes'),
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTerm,
                  items: _terms
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTerm = value!),
                  decoration: const InputDecoration(
                    labelText: 'Term',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Results Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('ADM No.')),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Average'), numeric: true),
                DataColumn(label: Text('Grade')),
                DataColumn(label: Text('Points')),
              ],
              rows: _students.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final student = entry.value;
                final totalMarks = _results
                    .where((r) => r.studentId == student.id)
                    .fold(0.0, (sum, r) => sum + r.marksObtained);
                final avgMarks =
                    _exams.isNotEmpty ? totalMarks / _exams.length : 0;
                final result = Result(
                    id: '',
                    examId: '',
                    studentId: student.id,
                    marksObtained: avgMarks.toDouble(),
                    gradedBy: '',
                    gradedAt: null);

                return DataRow(cells: [
                  DataCell(Text('#$index',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(student.fullName)),
                  DataCell(Text(student.admissionNumber)),
                  DataCell(Text(totalMarks.toStringAsFixed(0))),
                  DataCell(Text(avgMarks.toStringAsFixed(1))),
                  DataCell(Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getGradeColor(result.getGrade(100)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(result.getGradeDisplay()),
                  )),
                  DataCell(Text(result.getGradePoints())),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REPORT CARDS TAB ====================
  Widget _buildReportCardsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  value: _selectedClass,
                  hint: const Text('Select Class'),
                  items: _classes
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.name)))
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTerm,
                  items: _terms
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTerm = value!),
                  decoration: const InputDecoration(
                    labelText: 'Term',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
              ),
            ],
          ),
        ),
        // Report Cards List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ADM: ${student.admissionNumber}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReportCardSummary(student),
                          const SizedBox(height: 16),
                          const Text('Subject Performance',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._subjects.map((subject) => _buildSubjectResultRow(
                              subject.name, 85, 'A-', '11')),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Teacher Remarks',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.print),
                                  label: const Text('Print'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.email),
                                  label: const Text('Email to Parent'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCardSummary(Student student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Marks', '450', Colors.blue),
              _buildSummaryItem('Average', '90.0', Colors.green),
              _buildSummaryItem('Grade', 'A', Colors.orange),
              _buildSummaryItem('Position', '#1', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSubjectResultRow(
      String subject, double marks, String grade, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(subject)),
          SizedBox(
              width: 80,
              child: Text(marks.toString(), textAlign: TextAlign.center)),
          SizedBox(width: 60, child: Text(grade, textAlign: TextAlign.center)),
          SizedBox(width: 40, child: Text(points, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  // Helper methods
  Color _getExamTypeColor(ExamType type) {
    switch (type) {
      case ExamType.midterm:
        return Colors.orange;
      case ExamType.endTerm:
        return Colors.red;
      case ExamType.CAT:
        return Colors.blue;
      case ExamType.assignment:
        return Colors.green;
      case ExamType.practical:
        return Colors.purple;
    }
  }

  IconData _getExamTypeIcon(ExamType type) {
    switch (type) {
      case ExamType.midterm:
        return Icons.access_time;
      case ExamType.endTerm:
        return Icons.assignment_turned_in;
      case ExamType.CAT:
        return Icons.quiz;
      case ExamType.assignment:
        return Icons.assignment;
      case ExamType.practical:
        return Icons.computer;
    }
  }

  Color _getGradeColor(Grade grade) {
    switch (grade) {
      case Grade.A:
        return Colors.green;
      case Grade.A_minus:
        return Colors.green;
      case Grade.B_plus:
        return Colors.blue;
      case Grade.B:
        return Colors.blue;
      case Grade.B_minus:
        return Colors.teal;
      case Grade.C_plus:
        return Colors.orange;
      case Grade.C:
        return Colors.orange;
      case Grade.C_minus:
        return Colors.deepOrange;
      case Grade.D_plus:
        return Colors.red;
      case Grade.D:
        return Colors.red;
      case Grade.D_minus:
        return Colors.red;
      case Grade.E:
        return Colors.red;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
