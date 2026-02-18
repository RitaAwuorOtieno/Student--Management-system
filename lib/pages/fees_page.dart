import 'package:flutter/material.dart';
import '../models/fees.dart';
import '../services/firestore_service.dart';
import '../services/mpesa_service.dart';
import '../models/student.dart';

class FeesPage extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  late Stream<List<Fees>> _feesStream;
  late Stream<List<Discount>> _discountsStream;

  String _searchQuery = '';
  String _selectedAcademicYear = '2024';
  String _selectedTerm = 'Term 1';
  final List<String> _academicYears = ['2023', '2024', '2025'];
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3'];

  // Sample students for demo
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
  ];

  // Sample fee structures
  final List<FeeStructure> _feeStructures = [
    FeeStructure(
        id: 'fs1',
        className: 'Grade 1',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 15000,
        activityFee: 2000,
        examFee: 1000,
        transportFee: 5000,
        otherFee: 500,
        totalFee: 23500),
    FeeStructure(
        id: 'fs2',
        className: 'Grade 2',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 16000,
        activityFee: 2000,
        examFee: 1000,
        transportFee: 5000,
        otherFee: 500,
        totalFee: 24500),
    FeeStructure(
        id: 'fs3',
        className: 'Grade 3',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 17000,
        activityFee: 2500,
        examFee: 1500,
        transportFee: 5000,
        otherFee: 500,
        totalFee: 26500),
    FeeStructure(
        id: 'fs4',
        className: 'Form 1',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 25000,
        activityFee: 3000,
        examFee: 2000,
        transportFee: 5000,
        otherFee: 1000,
        totalFee: 36000),
    FeeStructure(
        id: 'fs5',
        className: 'Form 2',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 26000,
        activityFee: 3000,
        examFee: 2000,
        transportFee: 5000,
        otherFee: 1000,
        totalFee: 37000),
    FeeStructure(
        id: 'fs6',
        className: 'Form 3',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 27000,
        activityFee: 3500,
        examFee: 2500,
        transportFee: 5000,
        otherFee: 1000,
        totalFee: 39000),
    FeeStructure(
        id: 'fs7',
        className: 'Form 4',
        term: 'Term 1',
        academicYear: '2024',
        tuitionFee: 28000,
        activityFee: 3500,
        examFee: 3000,
        transportFee: 5000,
        otherFee: 1000,
        totalFee: 40500),
  ];

  // Sample payments
  final List<Payment> _payments = [
    Payment(
        id: 'p1',
        studentId: 's1',
        studentName: 'John Doe',
        amount: 23500,
        paymentDate: DateTime(2024, 1, 15),
        paymentMethod: 'Cash',
        receiptNumber: 'RCP-001',
        academicYear: '2024',
        term: 'Term 1'),
    Payment(
        id: 'p2',
        studentId: 's2',
        studentName: 'Jane Smith',
        amount: 12000,
        paymentDate: DateTime(2024, 1, 20),
        paymentMethod: 'M-Pesa',
        receiptNumber: 'RCP-002',
        academicYear: '2024',
        term: 'Term 1'),
    Payment(
        id: 'p3',
        studentId: 's3',
        studentName: 'Bob Johnson',
        amount: 23500,
        paymentDate: DateTime(2024, 1, 10),
        paymentMethod: 'Bank Transfer',
        receiptNumber: 'RCP-003',
        academicYear: '2024',
        term: 'Term 1'),
  ];

  // Sample discounts
  final List<Discount> _discounts = [
    Discount(
        id: 'd1',
        name: 'Early Payment',
        description: '5% discount for payment within first week of term',
        percentage: 5,
        isEarlyPayment: true,
        validFrom: '2024-01-01',
        validUntil: '2024-01-31'),
    Discount(
        id: 'd2',
        name: 'Sibling Discount',
        description: '10% discount for second and subsequent siblings',
        percentage: 10,
        isEarlyPayment: false,
        validFrom: '2024-01-01',
        validUntil: '2024-12-31'),
    Discount(
        id: 'd3',
        name: 'Staff Child',
        description: '25% discount for staff children',
        percentage: 25,
        isEarlyPayment: false,
        validFrom: '2024-01-01',
        validUntil: '2024-12-31'),
    Discount(
        id: 'd4',
        name: 'Full Payment',
        description: '5% discount for full term payment',
        percentage: 5,
        isEarlyPayment: false,
        validFrom: '2024-01-01',
        validUntil: '2024-01-31'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _feesStream = _firestoreService.getFees();
    _discountsStream = _firestoreService.getDiscounts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Payments'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fee Structure'),
            Tab(text: 'Student Fees'),
            Tab(text: 'Payments'),
            Tab(text: 'Discounts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeeStructureTab(),
          _buildStudentFeesTab(),
          _buildPaymentsTab(),
          _buildDiscountsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFeeStructureDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Fee Structure'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  // ==================== FEE STRUCTURE TAB ====================
  Widget _buildFeeStructureTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
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
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
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
        // Fee Structure Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _feeStructures.length,
            itemBuilder: (context, index) {
              final feeStructure = _feeStructures[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    '${feeStructure.className} - ${feeStructure.term} ${feeStructure.academicYear}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: KES ${feeStructure.totalFee.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildFeeDetailRow(
                              'Tuition Fee', feeStructure.tuitionFee),
                          _buildFeeDetailRow(
                              'Activity Fee', feeStructure.activityFee),
                          _buildFeeDetailRow('Exam Fee', feeStructure.examFee),
                          _buildFeeDetailRow(
                              'Transport Fee', feeStructure.transportFee),
                          _buildFeeDetailRow(
                              'Other Fee', feeStructure.otherFee),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                'KES ${feeStructure.totalFee.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _editFeeStructure(feeStructure),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _duplicateFeeStructure(feeStructure),
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Duplicate'),
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

  Widget _buildFeeDetailRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('KES ${amount.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  // ==================== STUDENT FEES TAB ====================
  Widget _buildStudentFeesTab() {
    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.payment,
                  label: 'Total Collected',
                  value: 'KES ${_getTotalCollected().toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.pending,
                  label: 'Pending',
                  value: 'KES ${_getTotalPending().toStringAsFixed(0)}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search student name or admission number...',
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
        // Student Fees List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final totalPaid = _payments
                  .where((p) => p.studentId == student.id)
                  .fold(0.0, (sum, p) => sum + p.amount);
              final totalFee =
                  _feeStructures.isNotEmpty ? _feeStructures[0].totalFee : 0;
              final balance = totalFee - totalPaid;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                    '${student.admissionNumber} | ${student.classGrade}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeeStatusItem('Total Fee',
                                'KES ${totalFee.toStringAsFixed(0)}'),
                            _buildFeeStatusItem(
                                'Paid', 'KES ${totalPaid.toStringAsFixed(0)}',
                                color: Colors.green),
                            _buildFeeStatusItem(
                                'Balance', 'KES ${balance.toStringAsFixed(0)}',
                                color: balance > 0 ? Colors.red : Colors.green),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showRecordPaymentDialog(student),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Record Payment'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
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

  Widget _buildFeeStatusItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ==================== PAYMENTS TAB ====================
  Widget _buildPaymentsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
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
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
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
        // Payments Summary
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.receipt,
                  label: 'Total Payments',
                  value: '${_payments.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.attach_money,
                  label: 'Total Amount',
                  value: 'KES ${_getTotalCollected().toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        // Payments List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.check, color: Colors.green),
                  ),
                  title: Text(payment.studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receipt: ${payment.receiptNumber}'),
                      Text(
                          'Date: ${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}'),
                      Text('Method: ${payment.paymentMethod}'),
                    ],
                  ),
                  trailing: Text(
                    'KES ${payment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green),
                  ),
                  onTap: () => _showReceiptDialog(payment),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== DISCOUNTS TAB ====================
  Widget _buildDiscountsTab() {
    final earlyPaymentDiscounts =
        _discounts.where((d) => d.isEarlyPayment).toList();
    final otherDiscounts = _discounts.where((d) => !d.isEarlyPayment).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (earlyPaymentDiscounts.isNotEmpty) ...[
            Row(
              children: const [
                Icon(Icons.timer, color: Colors.green),
                SizedBox(width: 8),
                Text('Early Payment Discounts',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...earlyPaymentDiscounts
                .map((discount) => _buildDiscountCard(discount)),
            const SizedBox(height: 24),
          ],
          Row(
            children: const [
              Icon(Icons.card_giftcard, color: Colors.blue),
              SizedBox(width: 8),
              Text('Other Discounts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...otherDiscounts.map((discount) => _buildDiscountCard(discount)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddDiscountDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add New Discount'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(Discount discount) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: discount.isEarlyPayment ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(discount.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: discount.isEarlyPayment ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${discount.percentage.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(discount.description),
            const SizedBox(height: 8),
            Text(
              'Valid: ${discount.validFrom} - ${discount.validUntil}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  double _getTotalCollected() {
    return _payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double _getTotalPending() {
    double totalFees = _feeStructures.isNotEmpty
        ? _feeStructures[0].totalFee * _students.length
        : 0;
    return totalFees - _getTotalCollected();
  }

  // ==================== DIALOGS ====================
  void _showAddFeeStructureDialog() {
    final nameController = TextEditingController();
    String selectedClass = 'Grade 1';
    int tuitionFee = 15000;
    int activityFee = 2000;
    int examFee = 1000;
    int transportFee = 5000;
    int otherFee = 500;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fee Structure'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedClass,
                items: [
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
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => selectedClass = value!,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              const SizedBox(height: 12),
              _buildNumberField('Tuition Fee (KES)', tuitionFee,
                  (value) => tuitionFee = value),
              _buildNumberField('Activity Fee (KES)', activityFee,
                  (value) => activityFee = value),
              _buildNumberField(
                  'Exam Fee (KES)', examFee, (value) => examFee = value),
              _buildNumberField('Transport Fee (KES)', transportFee,
                  (value) => transportFee = value),
              _buildNumberField(
                  'Other Fee (KES)', otherFee, (value) => otherFee = value),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'KES ${(tuitionFee + activityFee + examFee + transportFee + otherFee).toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
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
              setState(() {
                _feeStructures.add(FeeStructure(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  className: selectedClass,
                  term: _selectedTerm,
                  academicYear: _selectedAcademicYear,
                  tuitionFee: tuitionFee.toDouble(),
                  activityFee: activityFee.toDouble(),
                  examFee: examFee.toDouble(),
                  transportFee: transportFee.toDouble(),
                  otherFee: otherFee.toDouble(),
                  totalFee: (tuitionFee +
                          activityFee +
                          examFee +
                          transportFee +
                          otherFee)
                      .toDouble(),
                ));
              });
              Navigator.pop(context);
              _showSuccess('Fee structure added successfully');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: '),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () =>
                setState(() => onChanged(value > 0 ? value - 500 : 0)),
          ),
          Text(value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => onChanged(value + 500)),
          ),
        ],
      ),
    );
  }

  void _editFeeStructure(FeeStructure feeStructure) {
    // Edit dialog
  }

  void _duplicateFeeStructure(FeeStructure feeStructure) {
    setState(() {
      _feeStructures.add(FeeStructure(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        className: feeStructure.className,
        term: _selectedTerm,
        academicYear: _selectedAcademicYear,
        tuitionFee: feeStructure.tuitionFee,
        activityFee: feeStructure.activityFee,
        examFee: feeStructure.examFee,
        transportFee: feeStructure.transportFee,
        otherFee: feeStructure.otherFee,
        totalFee: feeStructure.totalFee,
      ));
    });
    _showSuccess('Fee structure duplicated');
  }

  void _showRecordPaymentDialog(Student student) {
    final amountController = TextEditingController();
    String paymentMethod = 'Cash';
    bool isLoading = false;
    final List<String> paymentMethods = [
      'Cash',
      'M-Pesa',
      'Bank Transfer',
      'Cheque'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(student.initials),
                ),
                title: Text(student.fullName),
                subtitle: Text('${student.admissionNumber}'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                items: paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: paymentMethod == 'M-Pesa' && isLoading
                    ? null
                    : (value) => setDialogState(() => paymentMethod = value!),
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
              if (paymentMethod == 'M-Pesa') ...[
                const SizedBox(height: 8),
                Text(
                  'M-Pesa STK push will be sent to your phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                Text('Sending STK push...'),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        // If M-Pesa, initiate STK push first
                        if (paymentMethod == 'M-Pesa') {
                          setDialogState(() => isLoading = true);

                          try {
                            // Get phone number from student or use parent phone
                            final phone = student.phone.isNotEmpty
                                ? student.phone
                                : student.parentPhone;

                            final result = await MpesaService.initiateSTKPush(
                              phone: phone,
                              amount: amount,
                              accountReference: student.admissionNumber,
                              transactionDesc:
                                  'School Fees - ${student.fullName}',
                            );

                            if (result['success'] == true) {
                              // Record payment after successful STK push
                              setState(() {
                                _payments.add(Payment(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  studentId: student.id,
                                  studentName: student.fullName,
                                  amount: amount,
                                  paymentDate: DateTime.now(),
                                  paymentMethod: paymentMethod,
                                  receiptNumber: result['checkoutRequestId'] ??
                                      'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                  academicYear: _selectedAcademicYear,
                                  term: _selectedTerm,
                                ));
                              });
                              Navigator.pop(context);
                              _showSuccess(
                                  'Payment recorded! STK push sent to $phone');
                            } else {
                              _showSuccess(
                                  result['message'] ?? 'STK push failed');
                            }
                          } catch (e) {
                            _showSuccess('Error: ${e.toString()}');
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        } else {
                          // For other payment methods, record directly
                          setState(() {
                            _payments.add(Payment(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              studentId: student.id,
                              studentName: student.fullName,
                              amount: amount,
                              paymentDate: DateTime.now(),
                              paymentMethod: paymentMethod,
                              receiptNumber:
                                  'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              academicYear: _selectedAcademicYear,
                              term: _selectedTerm,
                            ));
                          });
                          Navigator.pop(context);
                          _showSuccess('Payment recorded successfully');
                        }
                      }
                    },
              child: Text(paymentMethod == 'M-Pesa'
                  ? 'Send STK Push'
                  : 'Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('OFFICIAL RECEIPT',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildReceiptRow('Receipt Number:', payment.receiptNumber),
                  _buildReceiptRow('Student Name:', payment.studentName),
                  _buildReceiptRow('Date:',
                      '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}'),
                  _buildReceiptRow('Payment Method:', payment.paymentMethod),
                  _buildReceiptRow('Term:', payment.term),
                  _buildReceiptRow('Academic Year:', payment.academicYear),
                  const Divider(),
                  _buildReceiptRow('Amount Paid:',
                      'KES ${payment.amount.toStringAsFixed(0)}',
                      isBold: true),
                ],
              ),
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
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value,
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  void _showAddDiscountDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    int percentage = 5;
    bool isEarlyPayment = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Discount Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Percentage: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(
                      () => percentage = percentage > 5 ? percentage - 5 : 5),
                ),
                Text('$percentage%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => percentage += 5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Early Payment Discount'),
              value: isEarlyPayment,
              onChanged: (value) => setState(() => isEarlyPayment = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _discounts.add(Discount(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  percentage: percentage.toDouble(),
                  isEarlyPayment: isEarlyPayment,
                  validFrom: '2024-01-01',
                  validUntil: '2024-12-31',
                ));
              });
              Navigator.pop(context);
              _showSuccess('Discount added successfully');
            },
            child: const Text('Add'),
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
