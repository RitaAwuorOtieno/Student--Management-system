import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../provider/student_provider.dart';
import '../services/firestore_service.dart';
import 'fees_page.dart';
import 'course_outline_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  // Filter controllers
  String _filterClass = '';
  String _filterGender = '';
  String _filterStatus = '';

  // Available options
  final List<String> _classes = [
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4'
  ];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _statuses = ['Active', 'Inactive'];
  final List<String> _relationships = [
    'Father',
    'Mother',
    'Guardian',
    'Uncle',
    'Aunt',
    'Grandparent',
    'Other'
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _service.readAll();
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false)
            .setStudents(students);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error loading students: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final filteredStudents = provider.filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),

          // Stats Cards
          _buildStatsSection(provider),

          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return _buildStudentCard(student);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentForm(student: null),
        label: const Text('Add Student'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, admission number, parent...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<StudentProvider>(context, listen: false)
                            .setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              Provider.of<StudentProvider>(context, listen: false)
                  .setSearchQuery(value);
            },
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Class Filter
                FilterChip(
                  label: const Text('Class'),
                  selected: _filterClass.isNotEmpty,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (selected) {
                    setState(() {});
                    _showClassFilterDialog();
                  },
                  avatar: _filterClass.isNotEmpty
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
                const SizedBox(width: 8),
                // Gender Filter
                FilterChip(
                  label: const Text('Gender'),
                  selected: _filterGender.isNotEmpty,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (selected) {
                    _showGenderFilterDialog();
                  },
                  avatar: _filterGender.isNotEmpty
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
                const SizedBox(width: 8),
                // Status Filter
                FilterChip(
                  label: const Text('Status'),
                  selected: _filterStatus.isNotEmpty,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (selected) {
                    _showStatusFilterDialog();
                  },
                  avatar: _filterStatus.isNotEmpty
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
                const SizedBox(width: 8),
                // Clear Filters
                if (_filterClass.isNotEmpty ||
                    _filterGender.isNotEmpty ||
                    _filterStatus.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(StudentProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total', provider.totalCount, Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('Active', provider.activeCount, Colors.green),
          const SizedBox(width: 12),
          _buildStatCard('Inactive', provider.inactiveCount, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showStudentForm(student: null),
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Student'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final isActive = student.status == 'Active';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor:
              isActive ? Colors.blue.shade100 : Colors.grey.shade300,
          foregroundColor:
              isActive ? Colors.blue.shade700 : Colors.grey.shade600,
          child: student.photoUrl != null && student.photoUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(student.photoUrl!,
                      width: 56, height: 56, fit: BoxFit.cover),
                )
              : Text(
                  student.initials,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Adm: ${student.admissionNumber} | ${student.classGrade}'),
            Text('Parent: ${student.parentName} | ${student.parentPhone}'),
            Row(
              children: [
                Icon(
                  student.gender == 'Male' ? Icons.male : Icons.female,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(' | ${student.gender}'),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student.status,
                    style: TextStyle(
                      color: isActive
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, student),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Profile')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'fees', child: Text('Fees History')),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
        onTap: () => _showStudentProfile(student),
      ),
    );
  }

  void _handleMenuAction(String value, Student student) {
    switch (value) {
      case 'view':
        _showStudentProfile(student);
        break;
      case 'edit':
        _showStudentForm(student: student);
        break;
      case 'fees':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeesPage()),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(student);
        break;
    }
  }

  void _showStudentProfile(Student student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: student.status == 'Active'
                          ? Colors.blue.shade100
                          : Colors.grey.shade300,
                    ),
                    child:
                        student.photoUrl != null && student.photoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(student.photoUrl!,
                                    width: 100, height: 100, fit: BoxFit.cover),
                              )
                            : Center(
                                child: Text(
                                  student.initials,
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    student.fullName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: student.status == 'Active'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.status,
                      style: TextStyle(
                        color: student.status == 'Active'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileSection('Admission Details', [
                  _buildProfileRow('Admission Number', student.admissionNumber),
                  _buildProfileRow('Class/Grade', student.classGrade),
                  _buildProfileRow('Admission Date',
                      student.admissionDate?.toString().split(' ')[0] ?? 'N/A'),
                ]),
                const SizedBox(height: 16),
                _buildProfileSection('Personal Information', [
                  _buildProfileRow('Date of Birth',
                      student.dateOfBirth?.toString().split(' ')[0] ?? 'N/A'),
                  _buildProfileRow('Gender', student.gender),
                ]),
                const SizedBox(height: 16),
                _buildProfileSection('Parent/Guardian Information', [
                  _buildProfileRow('Name', student.parentName),
                  _buildProfileRow('Relationship', student.relationship),
                  _buildProfileRow('Phone', student.parentPhone),
                  _buildProfileRow(
                      'Email',
                      student.parentEmail.isNotEmpty
                          ? student.parentEmail
                          : 'N/A'),
                ]),
                const SizedBox(height: 16),
                _buildProfileSection('Contact Information', [
                  _buildProfileRow('Phone', student.phone),
                  _buildProfileRow('Email',
                      student.email.isNotEmpty ? student.email : 'N/A'),
                ]),
                const SizedBox(height: 16),
                _buildProfileSection('Address', [
                  _buildProfileRow('Address', student.address),
                  _buildProfileRow('City', student.city),
                  _buildProfileRow('County',
                      student.county.isNotEmpty ? student.county : 'N/A'),
                ]),
                if (student.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildProfileSection('Notes', [
                    Text(student.notes,
                        style: TextStyle(color: Colors.grey.shade700)),
                  ]),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showStudentForm(student: student);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FeesPage()),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Fees'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStudentForm({Student? student}) {
    final isEditing = student != null;

    // Controllers
    final _admissionController =
        TextEditingController(text: student?.admissionNumber ?? '');
    final _fullNameController =
        TextEditingController(text: student?.fullName ?? '');
    final _dobController = TextEditingController(
      text: student?.dateOfBirth != null
          ? '${student!.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}'
          : '',
    );
    final _classController =
        TextEditingController(text: student?.classGrade ?? '');
    final _parentNameController =
        TextEditingController(text: student?.parentName ?? '');
    final _parentPhoneController =
        TextEditingController(text: student?.parentPhone ?? '');
    final _parentEmailController =
        TextEditingController(text: student?.parentEmail ?? '');
    final _relationshipController =
        TextEditingController(text: student?.relationship ?? '');
    final _phoneController = TextEditingController(text: student?.phone ?? '');
    final _emailController = TextEditingController(text: student?.email ?? '');
    final _addressController =
        TextEditingController(text: student?.address ?? '');
    final _cityController = TextEditingController(text: student?.city ?? '');
    final _countyController =
        TextEditingController(text: student?.county ?? '');
    final _notesController = TextEditingController(text: student?.notes ?? '');

    String _gender = student?.gender ?? 'Male';
    String _status = student?.status ?? 'Active';
    DateTime? _selectedDob = student?.dateOfBirth;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Information Section
                _buildSectionHeader('Basic Information'),
                TextField(
                  controller: _admissionController,
                  decoration: const InputDecoration(
                    labelText: 'Admission Number *',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now()
                              .subtract(const Duration(days: 365 * 5)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDob = date;
                            _dobController.text =
                                '${date.day}/${date.month}/${date.year}';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: _genders
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value!),
                      decoration: const InputDecoration(labelText: 'Gender *'),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) => _classes.where(
                    (c) => c
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()),
                  ),
                  onSelected: (value) => _classController.text = value,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) =>
                          TextField(
                    controller: _classController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Class/Grade *',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _status = value!),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.toggle_on),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Parent/Guardian Details'),
                TextField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent/Guardian Name *',
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _relationshipController.text.isNotEmpty
                          ? _relationshipController.text
                          : null,
                      items: _relationships
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) => setState(
                          () => _relationshipController.text = value ?? ''),
                      decoration:
                          const InputDecoration(labelText: 'Relationship *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _parentPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: _parentEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Contact Information'),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Student Phone *',
                        prefixIcon: Icon(Icons.phone_iphone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSectionHeader('Address'),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _countyController,
                      decoration: const InputDecoration(
                        labelText: 'County',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSectionHeader('Additional Notes'),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validation
                if (_admissionController.text.trim().isEmpty ||
                    _fullNameController.text.trim().isEmpty ||
                    _classController.text.trim().isEmpty ||
                    _parentNameController.text.trim().isEmpty ||
                    _parentPhoneController.text.trim().isEmpty ||
                    _relationshipController.text.trim().isEmpty ||
                    _phoneController.text.trim().isEmpty ||
                    _addressController.text.trim().isEmpty ||
                    _cityController.text.trim().isEmpty) {
                  _showError('Please fill all required fields');
                  return;
                }

                final newStudent = Student(
                  id: student?.id ?? '',
                  admissionNumber: _admissionController.text.trim(),
                  fullName: _fullNameController.text.trim(),
                  dateOfBirth: _selectedDob,
                  gender: _gender,
                  classGrade: _classController.text.trim(),
                  status: _status,
                  parentName: _parentNameController.text.trim(),
                  parentPhone: _parentPhoneController.text.trim(),
                  parentEmail: _parentEmailController.text.trim(),
                  relationship: _relationshipController.text.trim(),
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  address: _addressController.text.trim(),
                  city: _cityController.text.trim(),
                  county: _countyController.text.trim(),
                  photoUrl: student?.photoUrl,
                  admissionDate: student?.admissionDate ?? DateTime.now(),
                  notes: _notesController.text.trim(),
                );

                try {
                  if (isEditing) {
                    await _service.update(newStudent);
                    if (mounted) {
                      Provider.of<StudentProvider>(context, listen: false)
                          .updateStudent(newStudent);
                      _showSuccess('Student updated successfully');
                    }
                  } else {
                    await _service.create(newStudent);
                    if (mounted) {
                      await _loadStudents();
                      _showSuccess('Student added successfully');
                    }
                  }
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  _showError('Error saving student: $e');
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete ${student.fullName}?'),
            const SizedBox(height: 8),
            Text(
              'Admission Number: ${student.admissionNumber}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _service.delete(student.id);
                if (mounted) {
                  Provider.of<StudentProvider>(context, listen: false)
                      .removeStudent(student.id);
                  Navigator.pop(context);
                  _showSuccess('Student deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showError('Error deleting student: $e');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClassFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Classes'),
              leading: Radio<String>(
                value: '',
                groupValue: _filterClass,
                onChanged: (value) {
                  setState(() => _filterClass = '');
                  Provider.of<StudentProvider>(context, listen: false)
                      .setFilterClass('');
                  Navigator.pop(context);
                },
              ),
            ),
            ..._classes.map((c) => ListTile(
                  title: Text(c),
                  leading: Radio<String>(
                    value: c,
                    groupValue: _filterClass,
                    onChanged: (value) {
                      setState(() => _filterClass = c);
                      Provider.of<StudentProvider>(context, listen: false)
                          .setFilterClass(c);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showGenderFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String>(
                value: '',
                groupValue: _filterGender,
                onChanged: (value) {
                  setState(() => _filterGender = '');
                  Provider.of<StudentProvider>(context, listen: false)
                      .setFilterGender('');
                  Navigator.pop(context);
                },
              ),
            ),
            ..._genders.map((g) => ListTile(
                  title: Text(g),
                  leading: Radio<String>(
                    value: g,
                    groupValue: _filterGender,
                    onChanged: (value) {
                      setState(() => _filterGender = g);
                      Provider.of<StudentProvider>(context, listen: false)
                          .setFilterGender(g);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String>(
                value: '',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = '');
                  Provider.of<StudentProvider>(context, listen: false)
                      .setFilterStatus('');
                  Navigator.pop(context);
                },
              ),
            ),
            ..._statuses.map((s) => ListTile(
                  title: Text(s),
                  leading: Radio<String>(
                    value: s,
                    groupValue: _filterStatus,
                    onChanged: (value) {
                      setState(() => _filterStatus = s);
                      Provider.of<StudentProvider>(context, listen: false)
                          .setFilterStatus(s);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filterClass = '';
      _filterGender = '';
      _filterStatus = '';
    });
    Provider.of<StudentProvider>(context, listen: false).clearFilters();
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
            child: const Text(
              'School Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Students'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Fees'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FeesPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Course Outline'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CourseOutlinePage()));
            },
          ),
        ],
      ),
    );
  }
}
