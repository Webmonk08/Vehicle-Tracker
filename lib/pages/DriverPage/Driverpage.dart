import 'package:flutter/material.dart';
import 'package:my_app/modals/DriverModal.dart';
import 'package:uuid/uuid.dart';


class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  List<Driver> drivers = [];
  final Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Sample drivers
    drivers = [
      Driver(id: uuid.v4(), name: 'Driver 1', PhoneNo: '9876543210'),
      Driver(id: uuid.v4(), name: 'Driver 2', PhoneNo: '9123456780'),
    ];
  }

  void _showAddEditDialog([Driver? driver]) {
    showDialog(
      context: context,
      builder: (context) => AddEditDriverDialog(
        driver: driver,
        onSave: (Driver newDriver) {
          setState(() {
            if (driver == null) {
              drivers.add(newDriver);
            } else {
              int index = drivers.indexWhere((d) => d.id == driver.id);
              if (index != -1) {
                drivers[index] = newDriver;
              }
            }
          });
        },
      ),
    );
  }

  void _deleteDriver(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Driver'),
        content: const Text('Are you sure you want to delete this driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                drivers.removeWhere((d) => d.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Drivers (${drivers.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: drivers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No drivers added yet',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the "Add Driver" button to get started',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.person,
                                color: Colors.blue[700], size: 24),
                          ),
                          title: Text(
                            driver.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('PhoneNo: ${driver.PhoneNo}',
                                  style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 2),
                              Text('ID: ${driver.id.substring(0, 8)}...',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500])),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.blue[600]),
                                onPressed: () => _showAddEditDialog(driver),
                                tooltip: 'Edit Driver',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red[600]),
                                onPressed: () => _deleteDriver(driver.id),
                                tooltip: 'Delete Driver',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddEditDriverDialog extends StatefulWidget {
  final Driver? driver;
  final Function(Driver) onSave;

  const AddEditDriverDialog({super.key, this.driver, required this.onSave});

  @override
  _AddEditDriverDialogState createState() => _AddEditDriverDialogState();
}

class _AddEditDriverDialogState extends State<AddEditDriverDialog> {
  late TextEditingController _nameController;
  late TextEditingController _PhoneNoController;
  final _formKey = GlobalKey<FormState>();
  final Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.driver?.name ?? '');
    _PhoneNoController =
        TextEditingController(text: widget.driver?.PhoneNo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _PhoneNoController.dispose();
    super.dispose();
  }

  void _saveDriver() {
    if (_formKey.currentState!.validate()) {
      final driver = Driver(
        id: widget.driver?.id ?? uuid.v4(),
        name: _nameController.text.trim(),
        PhoneNo: _PhoneNoController.text.trim(),
      );
      widget.onSave(driver);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.driver != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Driver' : 'Add Driver'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Driver Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Driver name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _PhoneNoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'PhoneNo Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'PhoneNo number is required';
                } else if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                  return 'Enter a valid 10-digit PhoneNo number';
                }
                return null;
              },
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fingerprint,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${widget.driver!.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveDriver,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
