import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:my_app/modals/vehicleModal.dart';
import 'package:my_app/data/vehicledata.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _VehicleTrackingPageState createState() => _VehicleTrackingPageState();
}

class _VehicleTrackingPageState extends State<Homepage> {
  List<Vehicle> vehicles = [];
  final Uuid uuid = Uuid();
  final Vehicledata vehicleInstance = Vehicledata();

  @override
  void initState() {
    super.initState();
    print("Initializing Vehicle Tracking Page...");
    loadvehicles();
  }

  Future<void> loadvehicles() async {
    print("Starting to load vehicles...");
    try {
      final loadedvehicles = await vehicleInstance.getVehicles();
      print("Raw loaded vehicles: $loadedvehicles");
      print("Vehicles count: ${loadedvehicles.length}");

      setState(() {
        vehicles = loadedvehicles;
      });
      print("State updated with ${vehicles.length} vehicles");
    } catch (e, stackTrace) {
      print('Error loading vehicles: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vehicles: ${e.toString()}')),
      );
    }
  }

  void _showAddEditDialog([Vehicle? vehicle]) {
    showDialog(
      context: context,
      builder: (context) => AddEditVehicleDialog(
        vehicle: vehicle,
        onSave: (Vehicle newVehicle) async {
          try {
            if (vehicle == null) {
              await vehicleInstance.addvehicle(newVehicle);
              vehicles.add(newVehicle);
            } else {
              await vehicleInstance.updateVehicle(vehicle.id, newVehicle);
              int index = vehicles.indexWhere((v) => v.id == vehicle.id);
              if (index != -1) {
                vehicles[index] = newVehicle;
              }
            }
          } catch (e) {
            print('object : $e');
          }
          setState(() {});
        },
      ),
    );
  }

  void _deleteVehicle(String id) async {
    // Find the vehicle to show its name in the confirmation
    final vehicle = vehicles.firstWhere((v) => v.id == id);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete "${vehicle.vehicleNo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleting vehicle...')));

        // Delete from database
        await vehicleInstance.deleteVehicle(id);

        // Update local state
        setState(() {
          vehicles.removeWhere((v) => v.id == id);
        });

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting vehicle: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
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
                  'Vehicle List (${vehicles.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Vehicle'),
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
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
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
                    padding: const EdgeInsets.all(16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
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
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            vehicle.vehicleNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[600],
                                ),
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

  const AddEditVehicleDialog({super.key, this.vehicle, required this.onSave});

  @override
  _AddEditVehicleDialogState createState() => _AddEditVehicleDialogState();
}

class _AddEditVehicleDialogState extends State<AddEditVehicleDialog> {
  late TextEditingController _VehicleNoController;
  final _formKey = GlobalKey<FormState>();
  final Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _VehicleNoController = TextEditingController(
      text: widget.vehicle?.vehicleNo ?? '',
    );
  }

  @override
  void dispose() {
    _VehicleNoController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? uuid.v4(),
        vehicleNo: _VehicleNoController.text.trim(),
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
              controller: _VehicleNoController,
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
                    Icon(Icons.fingerprint, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
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
          child: const Text('Cancel'),
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
