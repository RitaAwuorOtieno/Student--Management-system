import 'package:flutter/material.dart';
import '../models/academic_models.dart';
import '../models/user_model.dart';

class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  int _selectedTab = 0;

  // Sample data for demonstration
  final List<Subject> _subjects = [
    Subject(
        id: '1',
        name: 'Mathematics',
        code: 'MATH',
        category: 'Sciences',
        hoursPerWeek: 5),
    Subject(
        id: '2',
        name: 'English',
        code: 'ENG',
        category: 'Languages',
        hoursPerWeek: 4),
    Subject(
        id: '3',
        name: 'Kiswahili',
        code: 'KIS',
        category: 'Languages',
        hoursPerWeek: 4),
    Subject(
        id: '4',
        name: 'Science',
        code: 'SCI',
        category: 'Sciences',
        hoursPerWeek: 4),
    Subject(
        id: '5',
        name: 'Social Studies',
        code: 'SST',
        category: 'Humanities',
        hoursPerWeek: 3),
    Subject(
        id: '6',
        name: 'Religious Education',
        code: 'RE',
        category: 'Humanities',
        hoursPerWeek: 2),
    Subject(
        id: '7',
        name: 'Agriculture',
        code: 'AGR',
        category: 'Practical',
        hoursPerWeek: 2),
    Subject(
        id: '8',
        name: 'Art & Craft',
        code: 'ART',
        category: 'Arts',
        hoursPerWeek: 2),
  ];

  final List<SchoolClass> _classes = [
    SchoolClass(
        id: '1',
        name: 'Grade 1',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 101'),
    SchoolClass(
        id: '2',
        name: 'Grade 2',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 102'),
    SchoolClass(
        id: '3',
        name: 'Grade 3',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 103'),
    SchoolClass(
        id: '4',
        name: 'Grade 4',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 104'),
    SchoolClass(
        id: '5',
        name: 'Grade 5',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 105'),
    SchoolClass(
        id: '6',
        name: 'Grade 6',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 106'),
    SchoolClass(
        id: '7',
        name: 'Grade 7',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 107'),
    SchoolClass(
        id: '8',
        name: 'Grade 8',
        level: 'Primary',
        capacity: 40,
        roomNumber: 'Room 108'),
    SchoolClass(
        id: '9',
        name: 'Form 1',
        level: 'Secondary',
        capacity: 45,
        roomNumber: 'Room 201'),
    SchoolClass(
        id: '10',
        name: 'Form 2',
        level: 'Secondary',
        capacity: 45,
        roomNumber: 'Room 202'),
    SchoolClass(
        id: '11',
        name: 'Form 3',
        level: 'Secondary',
        capacity: 45,
        roomNumber: 'Room 203'),
    SchoolClass(
        id: '12',
        name: 'Form 4',
        level: 'Secondary',
        capacity: 45,
        roomNumber: 'Room 204'),
  ];

  final List<SubjectClassAssignment> _assignments = [];
  final List<String> _studentClassAssignments = [];

  // Sample teachers (in real app, fetch from users collection)
  final List<AppUser> _teachers = [
    AppUser(
        id: 't1',
        email: 'teacher1@school.com',
        fullName: 'Mr. John Smith',
        role: UserRole.teacher),
    AppUser(
        id: 't2',
        email: 'teacher2@school.com',
        fullName: 'Mrs. Jane Doe',
        role: UserRole.teacher),
    AppUser(
        id: 't3',
        email: 'teacher3@school.com',
        fullName: 'Mr. Robert Brown',
        role: UserRole.teacher),
    AppUser(
        id: 't4',
        email: 'teacher4@school.com',
        fullName: 'Ms. Emily White',
        role: UserRole.teacher),
  ];

  final List<String> _subjectCategories = [
    'Sciences',
    'Languages',
    'Humanities',
    'Practical',
    'Arts',
    'General'
  ];

  final List<String> _levels = ['Primary', 'Secondary'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Management'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'Subjects'),
            Tab(text: 'Classes'),
            Tab(text: 'Assignments'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildSubjectsTab(),
          _buildClassesTab(),
          _buildAssignmentsTab(),
        ],
      ),
    );
  }

  // ==================== SUBJECTS TAB ====================
  Widget _buildSubjectsTab() {
    return Column(
      children: [
        // Search and Add
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search subjects...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showSubjectDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Subjects List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      subject.code.substring(0, 2),
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(subject.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${subject.category} | ${subject.hoursPerWeek} hrs/week'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSubjectDialog(subject: subject),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubject(subject.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSubjectDialog({Subject? subject}) {
    final isEditing = subject != null;
    final _nameController = TextEditingController(text: subject?.name ?? '');
    final _codeController = TextEditingController(text: subject?.code ?? '');
    final _descController =
        TextEditingController(text: subject?.description ?? '');
    String _category = subject?.category ?? 'General';
    int _hours = subject?.hoursPerWeek ?? 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Subject' : 'Add New Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Subject Name *', prefixIcon: Icon(Icons.book)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                    labelText: 'Subject Code *', prefixIcon: Icon(Icons.code)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: _subjectCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => _category = value!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description)),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Hours/week: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      setState(() => _hours = (_hours > 1) ? _hours - 1 : 1),
                ),
                Text('$_hours',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _hours++),
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
                  _codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              if (isEditing) {
                // Update existing
                final index = _subjects.indexWhere((s) => s.id == subject!.id);
                if (index != -1) {
                  setState(() {
                    _subjects[index] = Subject(
                      id: subject.id,
                      name: _nameController.text,
                      code: _codeController.text,
                      category: _category,
                      description: _descController.text,
                      hoursPerWeek: _hours,
                    );
                  });
                }
              } else {
                // Add new
                setState(() {
                  _subjects.add(Subject(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    code: _codeController.text,
                    category: _category,
                    description: _descController.text,
                    hoursPerWeek: _hours,
                  ));
                });
              }
              Navigator.pop(context);
              _showSuccess(isEditing ? 'Subject updated' : 'Subject added');
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _subjects.removeWhere((s) => s.id == id));
              Navigator.pop(context);
              _showSuccess('Subject deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== CLASSES TAB ====================
  Widget _buildClassesTab() {
    // Group classes by level
    final primaryClasses = _classes.where((c) => c.level == 'Primary').toList();
    final secondaryClasses =
        _classes.where((c) => c.level == 'Secondary').toList();

    return Column(
      children: [
        // Search and Add
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search classes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showClassDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Classes List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (primaryClasses.isNotEmpty) ...[
                _buildSectionHeader('Primary School'),
                ...primaryClasses.map((c) => _buildClassCard(c)),
              ],
              if (secondaryClasses.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader('Secondary School'),
                ...secondaryClasses.map((c) => _buildClassCard(c)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildClassCard(SchoolClass schoolClass) {
    final classTeacher = _teachers.firstWhere(
      (t) => t.id == schoolClass.classTeacherId,
      orElse: () => AppUser(
          id: '', email: '', fullName: 'Not Assigned', role: UserRole.teacher),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(schoolClass.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${schoolClass.level} | Room: ${schoolClass.roomNumber ?? 'N/A'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 8),
                    Text('Capacity: ${schoolClass.capacity ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Text('Class Teacher: ${classTeacher.fullName}'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showAssignTeacherDialog(schoolClass),
                      child: const Text('Assign'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showClassDialog(schoolClass: schoolClass),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAssignStudentsDialog(schoolClass),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Students'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClass(schoolClass.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClassDialog({SchoolClass? schoolClass}) {
    final isEditing = schoolClass != null;
    final _nameController =
        TextEditingController(text: schoolClass?.name ?? '');
    String _level = schoolClass?.level ?? 'Primary';
    final _roomController =
        TextEditingController(text: schoolClass?.roomNumber ?? '');
    int _capacity = schoolClass?.capacity ?? 40;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Class Name *', prefixIcon: Icon(Icons.class_)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _level,
                items: _levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) => _level = value!,
                decoration: const InputDecoration(labelText: 'Level'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                    labelText: 'Room Number', prefixIcon: Icon(Icons.room)),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Capacity: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(
                      () => _capacity = (_capacity > 10) ? _capacity - 5 : 10),
                ),
                Text('$_capacity',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _capacity += 5),
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
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill class name')),
                );
                return;
              }

              if (isEditing) {
                final index =
                    _classes.indexWhere((c) => c.id == schoolClass!.id);
                if (index != -1) {
                  setState(() {
                    _classes[index] = SchoolClass(
                      id: schoolClass.id,
                      name: _nameController.text,
                      level: _level,
                      roomNumber: _roomController.text,
                      capacity: _capacity,
                      classTeacherId: schoolClass.classTeacherId,
                    );
                  });
                }
              } else {
                setState(() {
                  _classes.add(SchoolClass(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    level: _level,
                    roomNumber: _roomController.text,
                    capacity: _capacity,
                  ));
                });
              }
              Navigator.pop(context);
              _showSuccess(isEditing ? 'Class updated' : 'Class added');
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showAssignTeacherDialog(SchoolClass schoolClass) {
    String? selectedTeacher = schoolClass.classTeacherId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Class Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Class: ${schoolClass.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeacher,
              hint: const Text('Select Teacher'),
              items: _teachers
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.fullName),
                      ))
                  .toList(),
              onChanged: (value) => selectedTeacher = value,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final index = _classes.indexWhere((c) => c.id == schoolClass.id);
              if (index != -1) {
                setState(() {
                  _classes[index] =
                      _classes[index].copyWith(classTeacherId: selectedTeacher);
                });
              }
              Navigator.pop(context);
              _showSuccess('Class teacher assigned');
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showAssignStudentsDialog(SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Students to ${schoolClass.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Student assignment feature',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Select Students'),
              ),
              const SizedBox(height: 8),
              Text(
                  '${_studentClassAssignments.length} students currently assigned',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _deleteClass(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _classes.removeWhere((c) => c.id == id));
              Navigator.pop(context);
              _showSuccess('Class deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== ASSIGNMENTS TAB ====================
  Widget _buildAssignmentsTab() {
    return Column(
      children: [
        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignSubjectDialog(),
                  icon: const Icon(Icons.book),
                  label: const Text('Assign Subject to Class'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        // Assignments List
        Expanded(
          child: _assignments.isEmpty
              ? _buildEmptyAssignmentsState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    final subject = _subjects
                        .firstWhere((s) => s.id == assignment.subjectId);
                    final schoolClass =
                        _classes.firstWhere((c) => c.id == assignment.classId);
                    final teacher = _teachers
                        .firstWhere((t) => t.id == assignment.teacherId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.book, color: Colors.green.shade700),
                        ),
                        title: Text('${subject.name} - ${schoolClass.name}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Teacher: ${teacher.fullName}'),
                            if (assignment.daySchedule != null)
                              Text(
                                  '${assignment.daySchedule} | ${assignment.timeSlot ?? "Not scheduled"}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              setState(() => _assignments.removeAt(index));
                              _showSuccess('Assignment removed');
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit Schedule')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Remove',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAssignmentsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No subject assignments',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAssignSubjectDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Assignment'),
          ),
        ],
      ),
    );
  }

  void _showAssignSubjectDialog() {
    Subject? selectedSubject;
    SchoolClass? selectedClass;
    String? selectedTeacher;
    String? selectedDay;
    String? selectedTimeSlot;

    final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final _timeSlots = [
      '8:00 AM - 9:00 AM',
      '9:00 AM - 10:00 AM',
      '10:00 AM - 11:00 AM',
      '11:00 AM - 12:00 PM',
      '1:00 PM - 2:00 PM',
      '2:00 PM - 3:00 PM',
      '3:00 PM - 4:00 PM',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Subject to Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Subject>(
                hint: const Text('Select Subject'),
                items: _subjects
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (value) => selectedSubject = value,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SchoolClass>(
                hint: const Text('Select Class'),
                items: _classes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.name} (${c.level})'),
                        ))
                    .toList(),
                onChanged: (value) => selectedClass = value,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text('Select Teacher'),
                items: _teachers
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.fullName),
                        ))
                    .toList(),
                onChanged: (value) => selectedTeacher = value,
                decoration: const InputDecoration(labelText: 'Teacher'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text('Select Day'),
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => selectedDay = value,
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text('Select Time'),
                items: _timeSlots
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => selectedTimeSlot = value,
                decoration: const InputDecoration(labelText: 'Time Slot'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (selectedSubject == null ||
                  selectedClass == null ||
                  selectedTeacher == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all required fields')),
                );
                return;
              }

              setState(() {
                _assignments.add(SubjectClassAssignment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  subjectId: selectedSubject!.id,
                  classId: selectedClass!.id,
                  teacherId: selectedTeacher!,
                  daySchedule: selectedDay,
                  timeSlot: selectedTimeSlot,
                ));
              });

              Navigator.pop(context);
              _showSuccess('Subject assigned successfully');
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
