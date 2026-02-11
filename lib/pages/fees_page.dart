import 'package:flutter/material.dart';
import '../models/fees.dart';
import '../services/firestore_service.dart';
import '../services/mpesa_service.dart';

class FeesPage extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<Fees>> _feesStream;
  late Stream<List<Discount>> _discountsStream;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fees & Payments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Fees'),
              Tab(text: 'Discounts'),
            ],
          ),
        ),
        body: StreamBuilder<List<Fees>>(
          stream: _feesStream,
          builder: (context, feesSnapshot) {
            if (feesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (feesSnapshot.hasError) {
              return Center(child: Text('Error: ${feesSnapshot.error}'));
            }
            final fees = feesSnapshot.data ?? [];
            final filteredFees = fees.where((fee) {
              final matchesSearch = _searchQuery.isEmpty ||
                  fee.studentId.toLowerCase().contains(_searchQuery);
              return matchesSearch;
            }).toList();

            final totalPending = fees
                .where((f) => f.status == 'Pending' || f.status == 'Overdue')
                .fold<double>(0, (sum, f) => sum + f.amount);

            final totalPaid = fees
                .where((f) => f.status == 'Paid')
                .fold<double>(0, (sum, f) => sum + f.amount);

            return StreamBuilder<List<Discount>>(
              stream: _discountsStream,
              builder: (context, discountsSnapshot) {
                if (discountsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (discountsSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${discountsSnapshot.error}'));
                }
                final discounts = discountsSnapshot.data ?? [];

                return TabBarView(
                  children: [
                    // Fees Tab
                    _buildFeesTab(
                        filteredFees, totalPending, totalPaid, discounts),
                    // Discounts Tab
                    _buildDiscountsTab(discounts),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddFeesDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Fees'),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeesTab(List<Fees> filteredFees, double totalPending,
      double totalPaid, List<Discount> discounts) {
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
                  label: 'Total Paid',
                  value: '\$${totalPaid.toStringAsFixed(2)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.pending,
                  label: 'Pending',
                  value: '\$${totalPending.toStringAsFixed(2)}',
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
              hintText: 'Search by student ID...',
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
        // Fees List
        Expanded(
          child: filteredFees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No fees records found',
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
                  itemCount: filteredFees.length,
                  itemBuilder: (context, index) {
                    final fee = filteredFees[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(fee.status),
                          child: Icon(
                            _getStatusIcon(fee.status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Student: ${fee.studentId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                'Amount: \$${fee.amount.toStringAsFixed(2)} | Due: ${fee.dueDate}'),
                            Text(
                              'Status: ${fee.status}',
                              style: TextStyle(
                                color: _getStatusColor(fee.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (fee.status == 'Paid')
                              Text(
                                'Paid: ${fee.paymentDate} via ${fee.paymentMethod}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showEditFeeDialog(fee),
                              tooltip: 'Edit Fee',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              onPressed: () =>
                                  _confirmDeleteFee(fee.id, fee.studentId),
                              tooltip: 'Delete Fee',
                            ),
                            if (fee.status != 'Paid')
                              ElevatedButton(
                                onPressed: () =>
                                    _showPaymentDialog(fee, discounts),
                                child: const Text('Pay'),
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

  Widget _buildDiscountsTab(List<Discount> discounts) {
    final earlyPaymentDiscounts =
        discounts.where((d) => d.isEarlyPayment).toList();
    final otherDiscounts = discounts.where((d) => !d.isEarlyPayment).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Early Payment Discount Section
          if (earlyPaymentDiscounts.isNotEmpty) ...[
            Row(
              children: const [
                Icon(Icons.timer, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Early Payment Discounts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...earlyPaymentDiscounts.map((discount) =>
                _buildDiscountCard(discount, isEarlyPayment: true)),
            const SizedBox(height: 24),
          ],
          // Other Discounts Section
          Row(
            children: const [
              Icon(Icons.card_giftcard, color: Color(0xFF1976D2)),
              SizedBox(width: 8),
              Text(
                'Other Discounts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...otherDiscounts.map((discount) =>
              _buildDiscountCard(discount, isEarlyPayment: false)),
          const SizedBox(height: 16),
          // Add Discount Button
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

  Widget _buildDiscountCard(Discount discount, {required bool isEarlyPayment}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isEarlyPayment ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  discount.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isEarlyPayment ? Colors.green : const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${discount.percentage.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(discount.description),
            const SizedBox(height: 8),
            Text(
              'Valid: ${discount.validFrom} - ${discount.validUntil}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showEditDiscountDialog(discount),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _confirmDeleteDiscount(discount.id),
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
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending;
      case 'Overdue':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  void _showAddFeesDialog() {
    final studentIdController = TextEditingController();
    final amountController = TextEditingController();
    String selectedSemester = 'Fall';
    String academicYear = '2023-2024';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Fees'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: academicYear,
                items: const [
                  DropdownMenuItem(
                      value: '2023-2024', child: Text('2023-2024')),
                  DropdownMenuItem(
                      value: '2024-2025', child: Text('2024-2025')),
                ],
                onChanged: (value) => academicYear = value!,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
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
            onPressed: () async {
              final studentId = studentIdController.text.trim();
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;

              if (studentId.isNotEmpty && amount > 0) {
                final newFee = Fees(
                  id: '',
                  studentId: studentId,
                  amount: amount,
                  status: 'Pending',
                  dueDate:
                      '2024-01-15', // Default due date, can be made configurable
                  paymentDate: '',
                  paymentMethod: '',
                  academicYear: academicYear,
                  semester: selectedSemester,
                );
                await _firestoreService.createFees(newFee);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fees added successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all fields correctly.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Fees fee, List<Discount> discounts) {
    Discount? selectedDiscount;
    String selectedPaymentMethod = 'Bank Transfer';
    final TextEditingController phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isProcessing = false;
    String stkStatus = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Make Payment'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Student: ${fee.studentId}'),
                  const SizedBox(height: 8),
                  Text('Amount: \${fee.amount.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentMethod,
                    items: const [
                      DropdownMenuItem(
                          value: 'Bank Transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(
                          value: 'Credit Card', child: Text('Credit Card')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Check', child: Text('Check')),
                      DropdownMenuItem(value: 'M-Pesa', child: Text('M-Pesa')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                        stkStatus = '';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone number field for M-Pesa
                  if (selectedPaymentMethod == 'M-Pesa') ...[
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '07XX XXX XXX or 254XX XXX XXX',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (selectedPaymentMethod == 'M-Pesa') {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required for M-Pesa';
                          }
                          final error = MpesaService.validatePhoneNumber(value);
                          if (error != null) {
                            return error;
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You will receive an STK push on your phone',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (stkStatus.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: stkStatus.contains('success')
                              ? Colors.green.shade100
                              : stkStatus.contains('fail') ||
                                      stkStatus.contains('error')
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              stkStatus.contains('success')
                                  ? Icons.check_circle
                                  : stkStatus.contains('fail') ||
                                          stkStatus.contains('error')
                                      ? Icons.error
                                      : Icons.hourglass_empty,
                              color: stkStatus.contains('success')
                                  ? Colors.green
                                  : stkStatus.contains('fail') ||
                                          stkStatus.contains('error')
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                stkStatus,
                                style: TextStyle(
                                  color: stkStatus.contains('success')
                                      ? Colors.green
                                      : stkStatus.contains('fail') ||
                                              stkStatus.contains('error')
                                          ? Colors.red
                                          : Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  const Text('Apply discount?'),
                  ...discounts.map((discount) => RadioListTile<Discount>(
                        title: Text(
                            '${discount.name} (${discount.percentage.toStringAsFixed(0)}%)'),
                        value: discount,
                        groupValue: selectedDiscount,
                        onChanged: (value) =>
                            setState(() => selectedDiscount = value),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() => isProcessing = true);

                      final now = DateTime.now();
                      final paymentDate =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                      // Calculate final amount with discount
                      double finalAmount = selectedDiscount != null
                          ? fee.amount *
                              (1 - selectedDiscount!.percentage / 100)
                          : fee.amount;

                      // Handle M-Pesa payment
                      if (selectedPaymentMethod == 'M-Pesa') {
                        setState(() => stkStatus = 'Initiating STK push...');

                        final result = await MpesaService.initiateSTKPush(
                          phone: phoneController.text.trim(),
                          amount: finalAmount,
                          accountReference: fee.studentId,
                          transactionDesc: 'Fees payment for ${fee.studentId}',
                        );

                        if (result['success']) {
                          setState(() {
                            stkStatus =
                                'STK push sent! Check your phone and enter PIN.\n'
                                'Request ID: ${result['checkoutRequestId']}';
                          });

                          // Show success message but don't close dialog yet
                          // User needs to complete payment on their phone
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'STK push sent! Complete payment on your phone.'),
                              duration: Duration(seconds: 5),
                            ),
                          );

                          // For demo purposes, we can simulate payment completion
                          // In production, you would poll for callback status
                          await Future.delayed(const Duration(seconds: 3));

                          // Simulate successful payment (remove in production)
                          setState(() =>
                              stkStatus = 'Payment successful! (Demo mode)');

                          final updatedFee = Fees(
                            id: fee.id,
                            studentId: fee.studentId,
                            amount: finalAmount,
                            status: 'Paid',
                            dueDate: fee.dueDate,
                            paymentDate: paymentDate,
                            paymentMethod: 'M-Pesa',
                            academicYear: fee.academicYear,
                            semester: fee.semester,
                          );
                          await _firestoreService.updateFees(updatedFee);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Payment completed successfully!')),
                            );
                          }
                        } else {
                          setState(() {
                            stkStatus = 'Error: ${result['message']}';
                            isProcessing = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Payment failed: ${result['message']}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Handle other payment methods
                        final updatedFee = Fees(
                          id: fee.id,
                          studentId: fee.studentId,
                          amount: finalAmount,
                          status: 'Paid',
                          dueDate: fee.dueDate,
                          paymentDate: paymentDate,
                          paymentMethod: selectedPaymentMethod,
                          academicYear: fee.academicYear,
                          semester: fee.semester,
                        );
                        await _firestoreService.updateFees(updatedFee);

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Payment processed successfully!')),
                          );
                        }
                      }
                    },
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDiscountDialog() {
    final nameController = TextEditingController();
    final percentageController = TextEditingController();
    final descriptionController = TextEditingController();
    final validFromController = TextEditingController();
    final validUntilController = TextEditingController();
    bool isEarlyPayment = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Name',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Percentage (%)',
                    prefixIcon: Icon(Icons.percent),
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
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validFromController,
                  decoration: const InputDecoration(
                    labelText: 'Valid From (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validUntilController,
                  decoration: const InputDecoration(
                    labelText: 'Valid Until (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Early Payment Discount'),
                  value: isEarlyPayment,
                  onChanged: (value) =>
                      setState(() => isEarlyPayment = value ?? false),
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
                final name = nameController.text.trim();
                final percentage =
                    double.tryParse(percentageController.text.trim()) ?? 0.0;
                final description = descriptionController.text.trim();
                final validFrom = validFromController.text.trim();
                final validUntil = validUntilController.text.trim();

                if (name.isNotEmpty &&
                    percentage > 0 &&
                    description.isNotEmpty &&
                    validFrom.isNotEmpty &&
                    validUntil.isNotEmpty) {
                  final newDiscount = Discount(
                    id: '',
                    name: name,
                    percentage: percentage,
                    description: description,
                    validFrom: validFrom,
                    validUntil: validUntil,
                    isEarlyPayment: isEarlyPayment,
                  );
                  await _firestoreService.createDiscount(newDiscount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Discount added successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all fields correctly.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDiscountDialog(Discount discount) {
    final nameController = TextEditingController(text: discount.name);
    final percentageController =
        TextEditingController(text: discount.percentage.toString());
    final descriptionController =
        TextEditingController(text: discount.description);
    final validFromController = TextEditingController(text: discount.validFrom);
    final validUntilController =
        TextEditingController(text: discount.validUntil);
    bool isEarlyPayment = discount.isEarlyPayment;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Name',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Percentage (%)',
                    prefixIcon: Icon(Icons.percent),
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
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validFromController,
                  decoration: const InputDecoration(
                    labelText: 'Valid From (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validUntilController,
                  decoration: const InputDecoration(
                    labelText: 'Valid Until (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Early Payment Discount'),
                  value: isEarlyPayment,
                  onChanged: (value) =>
                      setState(() => isEarlyPayment = value ?? false),
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
                final name = nameController.text.trim();
                final percentage =
                    double.tryParse(percentageController.text.trim()) ?? 0.0;
                final description = descriptionController.text.trim();
                final validFrom = validFromController.text.trim();
                final validUntil = validUntilController.text.trim();

                if (name.isNotEmpty &&
                    percentage > 0 &&
                    description.isNotEmpty &&
                    validFrom.isNotEmpty &&
                    validUntil.isNotEmpty) {
                  final updatedDiscount = Discount(
                    id: discount.id,
                    name: name,
                    percentage: percentage,
                    description: description,
                    validFrom: validFrom,
                    validUntil: validUntil,
                    isEarlyPayment: isEarlyPayment,
                  );
                  await _firestoreService.updateDiscount(updatedDiscount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Discount updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all fields correctly.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDiscount(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Discount'),
        content: const Text(
            'Are you sure you want to delete this discount? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteDiscount(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discount deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFee(String feeId, String studentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Fee'),
        content: Text(
            'Are you sure you want to delete the fee for student "$studentId"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteFees(feeId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fee deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditFeeDialog(Fees fee) {
    final studentIdController = TextEditingController(text: fee.studentId);
    final amountController = TextEditingController(text: fee.amount.toString());
    String selectedSemester = fee.semester;
    String academicYear = fee.academicYear;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Fee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: academicYear,
                items: const [
                  DropdownMenuItem(
                      value: '2023-2024', child: Text('2023-2024')),
                  DropdownMenuItem(
                      value: '2024-2025', child: Text('2024-2025')),
                ],
                onChanged: (value) => academicYear = value!,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSemester,
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
            onPressed: () async {
              final studentId = studentIdController.text.trim();
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;

              if (studentId.isNotEmpty && amount > 0) {
                final updatedFee = Fees(
                  id: fee.id,
                  studentId: studentId,
                  amount: amount,
                  status: fee.status,
                  dueDate: fee.dueDate,
                  paymentDate: fee.paymentDate,
                  paymentMethod: fee.paymentMethod,
                  academicYear: academicYear,
                  semester: selectedSemester,
                );
                await _firestoreService.updateFees(updatedFee);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fee updated successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all fields correctly.')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
