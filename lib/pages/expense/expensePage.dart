import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/modals/expenseModal.dart';
import 'package:my_app/data/expenseData.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  List<Expensemodal> _expenses = [];
  List<String> _vehicleNumbers = [];
  String? _selectedVehicleNo; // Changed from " " to null
  bool _isLoading = true;
  bool _isLoadingVehicles = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadVehicleNumbers();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleNumbers() async {
    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      final vehicleNumbers = await _expenseService.getVehicleNumbers();
      setState(() {
        _vehicleNumbers = vehicleNumbers;
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
      });
      _showErrorSnackBar('Failed to load vehicle numbers: $e');
    }
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await _expenseService.getAllExpenses();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
      print(_expenses[0].toString());
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load expenses: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _addExpense() async {
    if (_selectedVehicleNo == null || _selectedVehicleNo!.trim().isEmpty) {
      _showErrorSnackBar('Please select a vehicle number');
      return;
    }

    if (_costController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter the cost');
      return;
    }

    // Validate cost is a valid number
    double? cost;
    try {
      cost = double.parse(_costController.text.trim());
      if (cost < 0) {
        _showErrorSnackBar('Cost cannot be negative');
        return;
      }
    } catch (e) {
      _showErrorSnackBar('Please enter a valid cost');
      return;
    }

    try {
      final expense = Expensemodal(
        vehicleNo: _selectedVehicleNo!.trim(), // Ensure it's trimmed
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        date: _dateController.text,
        expense: cost.toString(),
      );

      await _expenseService.addExpense(expense);
      
      // Clear form
      _selectedVehicleNo = null; // Reset to null
      _descriptionController.clear();
      _costController.clear();
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _selectedDate = DateTime.now();
      
      // Reload expenses
      await _loadExpenses();
      
      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      _showSuccessSnackBar('Expense added successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to add expense: $e');
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleNo,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number *',
                        border: OutlineInputBorder(),
                        hintText: 'Select vehicle number',
                      ),
                      isExpanded: true,
                      items: _isLoadingVehicles
                          ? [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading vehicles...'),
                                  ],
                                ),
                              ),
                            ]
                          : [
                              // Add a default "Select" option
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Select vehicle number'),
                              ),
                              ..._vehicleNumbers.map((String vehicleNo) {
                                return DropdownMenuItem<String>(
                                  value: vehicleNo,
                                  child: Text(vehicleNo),
                                );
                              }).toList(),
                            ],
                      onChanged: _isLoadingVehicles 
                          ? null 
                          : (String? newValue) {
                              setDialogState(() {
                                _selectedVehicleNo = newValue;
                              });
                              setState(() {
                                _selectedVehicleNo = newValue;
                        
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter expense cost',
                        prefixText: '₹ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Enter expense description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Clear form when cancelled
                    _selectedVehicleNo = null; // Reset to null
                    _descriptionController.clear();
                    _costController.clear();
                    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    _selectedDate = DateTime.now();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text('Add Expense'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildExpenseCard(Expensemodal expense) {
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            expense.vehicleNo.trim().isNotEmpty 
                ? expense.vehicleNo.trim().substring(0, 1).toUpperCase()
                : 'V',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          expense.vehicleNo.trim().isNotEmpty 
              ? expense.vehicleNo.trim()
              : 'Unknown Vehicle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(
                expense.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(expense.date),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                if (expense.expense.isNotEmpty)
                  Text(
                    '₹${expense.expense}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Add navigation to expense details if needed
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadExpenses();
              _loadVehicleNumbers();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _expenses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No expenses found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first expense',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExpenses,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      return _buildExpenseCard(_expenses[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}