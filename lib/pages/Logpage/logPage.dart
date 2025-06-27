import 'package:flutter/material.dart';
import 'package:my_app/modals/log_Modal.dart';
import 'package:my_app/data/log_page_data.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final LogPageData _logPageData = LogPageData();
  List<LogModal> _logs = [];
  List<LogModal> _filteredLogs = [];
  bool _isLoading = true;
  bool _isAddingLog = false;

  // Dropdown data
  List<dynamic> _vehicleNumbers = [];
  List<dynamic> _driverNames = [];
  bool _isLoadingDropdownData = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown selected values
  String? _selectedVehicleNo;
  String? _selectedDriverName;

  // Filter variables
  String? _filterVehicleNo;
  String? _filterDriverName;
  String? _filterDate;
  String? _filterEndDate;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _loadDropdownData();
    });

    try {
      final logs = await _logPageData.getLogs("", "", "", "", _isFilterApplied);

      setState(() {
        _logs = logs;
        _filteredLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load logs: $e');
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingDropdownData = true;
    });

    try {
      print("DropDown");
      final vehicleNumbers = await _logPageData.getVehicleNumbers();
      final driverNames = await _logPageData.getDriverNames();
      setState(() {
        _vehicleNumbers = vehicleNumbers.map((p) => p.toString()).toList();
        _driverNames = driverNames.map((p) => p.toString()).toList();
        _isLoadingDropdownData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDropdownData = false;
      });
      _showErrorSnackBar('Failed to load dropdown data: $e');
      print('Failed to load dropdown data: $e');
    }
  }

  void _applyFilters() async {
    _isFilterApplied =
        _filterVehicleNo != null ||
        _filterDriverName != null ||
        _filterDate != null ||
        _filterEndDate != null;

        
    _logs = await _logPageData.getLogs(
      _filterDate,
      _filterEndDate,
      _filterDriverName,
      _filterVehicleNo,
      _isFilterApplied,
    );
    setState(() {
      _filteredLogs = _logs.where((log) {
        bool matchesVehicle =
            _filterVehicleNo == null || log.vehicleNo == _filterVehicleNo;
        bool matchesDriver =
            _filterDriverName == null || log.driverName == _filterDriverName;
        bool matchesDate = _filterDate == null || log.date == _filterDate;

        return matchesVehicle && matchesDriver && matchesDate;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _filterVehicleNo = null;
      _filterDriverName = null;
      _filterDate = null;
      _filteredLogs = _logs;
      _isFilterApplied = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    String? tempVehicleNo = _filterVehicleNo;
    String? tempDriverName = _filterDriverName;
    String? tempDate = _filterDate;
    String? tempEndDate = _filterEndDate;
    final tempDateController = TextEditingController(text: _filterDate);
    final tempendDateController = TextEditingController(text: _filterEndDate);

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Logs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filter fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Vehicle Number filter
                        DropdownButtonFormField<String>(
                          value: tempVehicleNo,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Vehicle Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.directions_car),
                          ),
                          hint: const Text('Select Vehicle Number'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Vehicles'),
                            ),
                            ..._vehicleNumbers.map<DropdownMenuItem<String>>((
                              vehicle,
                            ) {
                              String vehicleNo = vehicle is Map
                                  ? vehicle['vehicle_number']?.toString() ??
                                        vehicle.toString()
                                  : vehicle.toString();
                              return DropdownMenuItem<String>(
                                value: vehicleNo,
                                child: Text(vehicleNo),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            setModalState(() {
                              tempVehicleNo = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Driver Name filter
                        DropdownButtonFormField<String>(
                          value: tempDriverName,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Driver Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          hint: const Text('Select Driver Name'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Drivers'),
                            ),
                            ..._driverNames.map<DropdownMenuItem<String>>((
                              driver,
                            ) {
                              String driverName = driver is Map
                                  ? driver['driver_name']?.toString() ??
                                        driver.toString()
                                  : driver.toString();
                              return DropdownMenuItem<String>(
                                value: driverName,
                                child: Text(driverName),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            setModalState(() {
                              tempDriverName = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date filter
                        TextFormField(
                          controller: tempDateController,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Date',
                            hintText: 'Select date to filter',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.clear),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              setModalState(() {
                                tempDate = formattedDate;
                                tempDateController.text = formattedDate;
                              });
                            }
                          },
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: tempendDateController,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Date',
                            hintText: 'Select End date to filter',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.clear),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              setModalState(() {
                                tempEndDate = formattedDate;
                                tempendDateController.text = formattedDate;
                              });
                            }
                          },
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),

                        // Clear filters button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempVehicleNo = null;
                                tempDriverName = null;
                                tempDate = null;
                                tempDateController.clear();
                                tempendDateController.clear();
                              });
                            },
                            child: const Text('Clear All Filters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterVehicleNo = tempVehicleNo;
                        _filterDriverName = tempDriverName;
                        _filterDate = tempDate;
                        _filterEndDate = tempEndDate;
                      });
                      _applyFilters();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];

    if (_filterVehicleNo != null) {
      chips.add(
        Chip(
          label: Text('Vehicle: $_filterVehicleNo'),
          onDeleted: () {
            setState(() {
              _filterVehicleNo = null;
            });
            _applyFilters();
          },
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
      );
    }

    if (_filterDriverName != null) {
      chips.add(
        Chip(
          label: Text('Driver: $_filterDriverName'),
          onDeleted: () {
            setState(() {
              _filterDriverName = null;
            });
            _applyFilters();
          },
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
      );
    }

    if (_filterDate != null) {
      chips.add(
        Chip(
          label: Text('Start-Date: $_filterDate'),
          onDeleted: () {
            setState(() {
              _filterDate = null;
            });
            _applyFilters();
          },
          backgroundColor: Colors.orange.withOpacity(0.1),
        ),
      );
    }
    if (_filterEndDate != null) {
      chips.add(
        Chip(
          label: Text('End-Date: $_filterEndDate'),
          onDeleted: () {
            setState(() {
              _filterEndDate = null;
            });
            _applyFilters();
          },
          backgroundColor: Colors.orange.withOpacity(0.1),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Filters:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );
  }

  Future<void> _addNewLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAddingLog = true;
    });

    try {
      await _logPageData.addLog(
        date: _dateController.text,
        vehicleNo: _selectedVehicleNo!,
        driverName: _selectedDriverName!,
        cost: double.tryParse(_costController.text) ?? 0,
        description: _descriptionController.text,
      );

      _clearForm();

      await _loadLogs();
      Navigator.of(context).pop();

      _showSuccessSnackBar('Log added successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to add log: $e');
    } finally {
      setState(() {
        _isAddingLog = false;
      });
    }
  }

  void _clearForm() {
    _dateController.clear();
    _costController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedVehicleNo = null;
      _selectedDriverName = null;
    });
  }

  void _showAddLogBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddLogBottomSheet(),
    );
  }

  Widget _buildAddLogBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Log',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Date field
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a date';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            _dateController.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          }
                        },
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Number dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleNo,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        hint: _isLoadingDropdownData
                            ? const Text('Loading vehicles...')
                            : const Text('Select Vehicle Number'),
                        items: _vehicleNumbers.map<DropdownMenuItem<String>>((
                          vehicle,
                        ) {
                          // Extract the vehicle number based on your data structure
                          String vehicleNo = vehicle is Map
                              ? vehicle['vehicle_number']?.toString() ??
                                    vehicle.toString()
                              : vehicle.toString();
                          return DropdownMenuItem<String>(
                            value: vehicleNo,
                            child: Text(vehicleNo),
                          );
                        }).toList(),
                        onChanged: _isLoadingDropdownData
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedVehicleNo = newValue;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a vehicle number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Driver Name dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedDriverName,
                        decoration: const InputDecoration(
                          labelText: 'Driver Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        hint: _isLoadingDropdownData
                            ? const Text('Loading drivers...')
                            : const Text('Select Driver Name'),
                        items: _driverNames.map<DropdownMenuItem<String>>((
                          driver,
                        ) {
                          // Extract the driver name based on your data structure
                          String driverName = driver is Map
                              ? driver['driver_name']?.toString() ??
                                    driver.toString()
                              : driver.toString();
                          return DropdownMenuItem<String>(
                            value: driverName,
                            child: Text(driverName),
                          );
                        }).toList(),
                        onChanged: _isLoadingDropdownData
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedDriverName = newValue;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a driver name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cost field
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cost';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isAddingLog ? null : _addNewLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isAddingLog
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Log', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(LogModal log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹${log.cost_of_load}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Vehicle: ${log.vehicleNo}'),
                const SizedBox(width: 20),
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text('Driver: ${log.driverName}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_isFilterApplied)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _loadLogs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_isFilterApplied) _buildFilterChips(),

          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFilterApplied
                              ? Icons.search_off
                              : Icons.description_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isFilterApplied
                              ? 'No logs match your filters'
                              : 'No logs found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isFilterApplied
                              ? 'Try adjusting your filter criteria'
                              : 'Add your first log by tapping the + button',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (_isFilterApplied) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    child: ListView.builder(
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        return _buildLogCard(_filteredLogs[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogBottomSheet,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
