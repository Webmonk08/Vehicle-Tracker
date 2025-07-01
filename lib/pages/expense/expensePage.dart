import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/modals/expenseModal.dart';
import 'package:my_app/data/expenseData.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  List<Expensemodal> _expenses = [];
  List<Expensemodal> _filteredExpenses = [];
  List<String> _vehicleNumbers = [];
  String? _selectedVehicleNo;
  bool _isLoading = true;
  bool _isLoadingVehicles = false;
  DateTime _selectedDate = DateTime.now();

  // Filter variables
  String? _filterVehicleNo;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _isFilterActive = false;

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
      setState(() {
        _expenses = expenses;
        _filteredExpenses = expenses;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load expenses: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        bool matchesVehicle = _filterVehicleNo == null || 
            expense.vehicleNo.toLowerCase().contains(_filterVehicleNo!.toLowerCase());
        
        bool matchesDate = true;
        if (_filterStartDate != null || _filterEndDate != null) {
          try {
            DateTime expenseDate = DateTime.parse(expense.date);
            if (_filterStartDate != null) {
              matchesDate = expenseDate.isAfter(_filterStartDate!.subtract(const Duration(days: 1)));
            }
            if (_filterEndDate != null && matchesDate) {
              matchesDate = expenseDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
            }
          } catch (e) {
            matchesDate = false;
          }
        }
        
        return matchesVehicle && matchesDate;
      }).toList();
      
      _isFilterActive = _filterVehicleNo != null || _filterStartDate != null || _filterEndDate != null;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterVehicleNo = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filteredExpenses = _expenses;
      _isFilterActive = false;
    });
  }

  void _showFilterDialog() {
    String? tempFilterVehicleNo = _filterVehicleNo;
    DateTime? tempFilterStartDate = _filterStartDate;
    DateTime? tempFilterEndDate = _filterEndDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Expenses'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vehicle Number Filter
                    DropdownButtonFormField<String>(
                      value: tempFilterVehicleNo,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Vehicle Number',
                        border: OutlineInputBorder(),
                        hintText: 'All vehicles',
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All vehicles'),
                        ),
                        ..._vehicleNumbers.map((String vehicleNo) {
                          return DropdownMenuItem<String>(
                            value: vehicleNo,
                            child: Text(vehicleNo),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempFilterVehicleNo = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date Filter
                    ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(
                        tempFilterStartDate != null
                            ? DateFormat('MMM dd, yyyy').format(tempFilterStartDate!)
                            : 'No start date selected',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempFilterStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  tempFilterStartDate = picked;
                                });
                              }
                            },
                          ),
                          if (tempFilterStartDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  tempFilterStartDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    // End Date Filter
                    ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(
                        tempFilterEndDate != null
                            ? DateFormat('MMM dd, yyyy').format(tempFilterEndDate!)
                            : 'No end date selected',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempFilterEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  tempFilterEndDate = picked;
                                });
                              }
                            },
                          ),
                          if (tempFilterEndDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  tempFilterEndDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterVehicleNo = tempFilterVehicleNo;
                      _filterStartDate = tempFilterStartDate;
                      _filterEndDate = tempFilterEndDate;
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
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
    // Validate vehicle selection
    if (_selectedVehicleNo == null || _selectedVehicleNo!.trim().isEmpty) {
      _showErrorSnackBar('Please select a vehicle number');
      return;
    }

    // Validate cost input
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
        vehicleNo: _selectedVehicleNo!.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _dateController.text,
        expense: cost.toString(),
      );

      await _expenseService.addExpense(expense);

      // Clear form
      setState(() {
        _selectedVehicleNo = null;
      });
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
    // Reset form state when opening dialog
    _selectedVehicleNo = null;
    _descriptionController.clear();
    _costController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedDate = DateTime.now();

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
                    // Vehicle Number Dropdown
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading vehicles...'),
                                  ],
                                ),
                              ),
                            ]
                          : [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Select vehicle number'),
                              ),
                              ..._vehicleNumbers.map((String vehicleNo) {
                                return DropdownMenuItem<String>(
                                  value: vehicleNo,
                                  child: Text(vehicleNo),
                                );
                              }),
                            ],
                      onChanged: _isLoadingVehicles
                          ? null
                          : (String? newValue) {
                              setDialogState(() {
                                _selectedVehicleNo = newValue;
                              });
                            },
                    ),
                    const SizedBox(height: 16),

                    // Cost Input
                    TextField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter expense cost',
                        prefixText: '₹ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Input
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Enter expense description (optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Date Input
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
          duration: const Duration(seconds: 3),
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
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFilterChip() {
    if (!_isFilterActive) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (_filterVehicleNo != null)
                  Chip(
                    label: Text('Vehicle: $_filterVehicleNo'),
                    onDeleted: () {
                      setState(() {
                        _filterVehicleNo = null;
                      });
                      _applyFilters();
                    },
                  ),
                if (_filterStartDate != null)
                  Chip(
                    label: Text('From: ${DateFormat('MMM dd').format(_filterStartDate!)}'),
                    onDeleted: () {
                      setState(() {
                        _filterStartDate = null;
                      });
                      _applyFilters();
                    },
                  ),
                if (_filterEndDate != null)
                  Chip(
                    label: Text('To: ${DateFormat('MMM dd').format(_filterEndDate!)}'),
                    onDeleted: () {
                      setState(() {
                        _filterEndDate = null;
                      });
                      _applyFilters();
                    },
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null && expense.description!.isNotEmpty) ...[
              Text(
                expense.description!,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(expense.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
      return dateString; // Return original string if parsing fails
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
            icon: Icon(
              Icons.filter_list,
              color: _isFilterActive ? Colors.yellow : Colors.white,
            ),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadExpenses();
              _loadVehicleNumbers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChip(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFilterActive ? Icons.search_off : Icons.receipt_long,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isFilterActive ? 'No expenses match your filters' : 'No expenses found',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isFilterActive
                                  ? 'Try adjusting your filter criteria'
                                  : 'Add your first expense using the + button',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadExpenses,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredExpenses.length,
                          itemBuilder: (context, index) {
                            return _buildExpenseCard(_filteredExpenses[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}