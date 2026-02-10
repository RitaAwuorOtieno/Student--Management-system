import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseOutlinePage extends StatefulWidget {
  const CourseOutlinePage({super.key});

  @override
  State<CourseOutlinePage> createState() => _CourseOutlinePageState();
}

class _CourseOutlinePageState extends State<CourseOutlinePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedYear = 1;

  // Sample course data - replace with Firestore data
  final List<Course> _courses = [
    Course(
      id: '1',
      code: 'CS101',
      name: 'Introduction to Computer Science',
      credits: 3,
      description: 'Basic concepts of programming and computational thinking',
      semester: 'Fall',
      year: 1,
    ),
    Course(
      id: '2',
      code: 'MATH101',
      name: 'Calculus I',
      credits: 4,
      description: 'Limits, derivatives, and integrals',
      semester: 'Fall',
      year: 1,
    ),
    Course(
      id: '3',
      code: 'CS102',
      name: 'Data Structures',
      credits: 3,
      description: 'Arrays, linked lists, trees, graphs, and algorithms',
      semester: 'Spring',
      year: 1,
    ),
    Course(
      id: '4',
      code: 'CS201',
      name: 'Algorithms',
      credits: 3,
      description: 'Design and analysis of algorithms',
      semester: 'Fall',
      year: 2,
    ),
    Course(
      id: '5',
      code: 'CS202',
      name: 'Database Systems',
      credits: 3,
      description: 'Relational databases, SQL, and database design',
      semester: 'Spring',
      year: 2,
    ),
    Course(
      id: '6',
      code: 'CS301',
      name: 'Software Engineering',
      credits: 4,
      description: 'Software development lifecycle and methodologies',
      semester: 'Fall',
      year: 3,
    ),
    Course(
      id: '7',
      code: 'CS302',
      name: 'Web Development',
      credits: 3,
      description: 'HTML, CSS, JavaScript, and web frameworks',
      semester: 'Spring',
      year: 3,
    ),
    Course(
      id: '8',
      code: 'CS401',
      name: 'Machine Learning',
      credits: 3,
      description: 'Introduction to ML algorithms and applications',
      semester: 'Fall',
      year: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _courses.where((course) {
      final matchesYear = course.year == _selectedYear;
      final matchesSearch = _searchQuery.isEmpty ||
          course.code.toLowerCase().contains(_searchQuery) ||
          course.name.toLowerCase().contains(_searchQuery);
      return matchesYear && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Outline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCourseDialog(),
            tooltip: 'Add Course',
          ),
        ],
      ),
      body: Column(
        children: [
          // Year Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Year:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(4, (index) {
                      final year = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedYear == year,
                          label: Text('Year $year'),
                          onSelected: (selected) {
                            setState(() => _selectedYear = year);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Course List
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No courses found for Year $_selectedYear',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            child: Text(
                              course.code.substring(0, 2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              '${course.code} | ${course.credits} Credits'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(course.description),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoChip(
                                        Icons.calendar_today,
                                        'Semester ${course.semester}',
                                      ),
                                      _buildInfoChip(
                                        Icons.numbers,
                                        '${course.credits} Credits',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            _showCourseDialog(course: course),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () =>
                                            _confirmDelete(course.id),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showCourseDialog({Course? course}) {
    final codeController = TextEditingController(text: course?.code ?? '');
    final nameController = TextEditingController(text: course?.name ?? '');
    final creditsController =
        TextEditingController(text: course?.credits.toString() ?? '3');
    final descriptionController =
        TextEditingController(text: course?.description ?? '');
    String selectedSemester = course?.semester ?? 'Fall';
    int selectedYear = course?.year ?? 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(course == null ? 'Add New Course' : 'Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  prefixIcon: Icon(Icons.menu_book),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedYear,
                items: List.generate(4, (index) => index + 1).map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('Year $year'),
                  );
                }).toList(),
                onChanged: (value) => selectedYear = value!,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedSemester,
                items: const [
                  DropdownMenuItem(value: 'Fall', child: Text('Fall')),
                  DropdownMenuItem(value: 'Spring', child: Text('Spring')),
                  DropdownMenuItem(value: 'Summer', child: Text('Summer')),
                ],
                onChanged: (value) => selectedSemester = value!,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
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
            onPressed: () {
              // Save course logic here
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
