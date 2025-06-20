import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Vehicle model
class Vehicle {
  final String id;
  final String vehicleNo;
  final String? type;

  Vehicle({
    required this.id,
    required this.vehicleNo,
    this.type,
  });

  Vehicle copyWith({
    String? id,
    String? vehicleNo,
    String? type,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      type: type ?? this.type,
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _VehicleTrackingPageState createState() => _VehicleTrackingPageState();
}

class _VehicleTrackingPageState extends State<Homepage> {
  List<Vehicle> vehicles = [];
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // Add some sample data
    vehicles = [
      Vehicle(id: uuid.v4(), vehicleNo: "TN01AB1234", type: "Car"),
      Vehicle(id: uuid.v4(), vehicleNo: "TN02CD5678", type: "Truck"),
      Vehicle(id: uuid.v4(), vehicleNo: "TN03EF9012"),
    ];
  }

  void _showAddEditDialog([Vehicle? vehicle]) {
    showDialog(
      context: context,
      builder: (context) => AddEditVehicleDialog(
        vehicle: vehicle,
        onSave: (Vehicle newVehicle) {
          setState(() {
            if (vehicle == null) {
              // Add new vehicle
              vehicles.add(newVehicle);
            } else {
              // Edit existing vehicle
              int index = vehicles.indexWhere((v) => v.id == vehicle.id);
              if (index != -1) {
                vehicles[index] = newVehicle;
              }
            }
          });
          },
      ),
    );
  }

  void _deleteVehicle(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                vehicles.removeWhere((v) => v.id == id);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
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
          // Header section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle List (${vehicles.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: Icon(Icons.add),
                  label: Text('Add Vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Vehicle list
          Expanded(
            child: vehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No vehicles added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the "Add Vehicle" button to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            vehicle.vehicleNo,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Type: ${vehicle.type ?? 'Not specified'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ID: ${vehicle.id.substring(0, 8)}...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showAddEditDialog(vehicle),
                                icon: Icon(Icons.edit, color: Colors.blue[600]),
                                tooltip: 'Edit Vehicle',
                              ),
                              IconButton(
                                onPressed: () => _deleteVehicle(vehicle.id),
                                icon: Icon(Icons.delete, color: Colors.red[600]),
                                tooltip: 'Delete Vehicle',
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

class AddEditVehicleDialog extends StatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle) onSave;

  AddEditVehicleDialog({
    this.vehicle,
    required this.onSave,
  });

  @override
  _AddEditVehicleDialogState createState() => _AddEditVehicleDialogState();
}

class _AddEditVehicleDialogState extends State<AddEditVehicleDialog> {
  late TextEditingController _vehicleNoController;
  late TextEditingController _typeController;
  final _formKey = GlobalKey<FormState>();
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _vehicleNoController = TextEditingController(
      text: widget.vehicle?.vehicleNo ?? '',
    );
    _typeController = TextEditingController(
      text: widget.vehicle?.type ?? '',
    );
  }

  @override
  void dispose() {
    _vehicleNoController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? uuid.v4(),
        vehicleNo: _vehicleNoController.text.trim(),
        type: _typeController.text.trim().isEmpty 
            ? null 
            : _typeController.text.trim(),
      );
      
      widget.onSave(vehicle);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _vehicleNoController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number *',
                hintText: 'e.g., TN01AB1234',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vehicle number is required';
                }
                return null;
              },
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Vehicle Type (Optional)',
                hintText: 'e.g., Car, Truck, Bus',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            if (isEditing) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fingerprint, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${widget.vehicle!.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveVehicle,
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