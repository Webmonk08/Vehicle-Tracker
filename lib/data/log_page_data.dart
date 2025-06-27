import 'package:my_app/modals/log_Modal.dart';
import 'package:my_app/modals/vehicleModal.dart';
import 'package:my_app/service/supabaseService.dart';
import 'package:my_app/modals/DriverModal.dart';

class LogPageData {
  final supabaseClient = SupabaseService.client;

Future<List<Driver>> getDriverNames() async {
  try {
    final response = await supabaseClient
        .from('drivers')
        .select('name');
    return (response as List)
        .map((row) => Driver.fromMap(row as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
}
Future<List<Vehicle>> getVehicleNumbers() async {
  try {
    final response = await supabaseClient
        .from('vehicles')
        .select('VehicleNo');

    return (response as List)
        .map((row) => Vehicle.fromMap(row as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
}

Future<List<LogModal>> getLogs() async {
  try {
    final List<Map<String, dynamic>> response = await supabaseClient
        .from('vehicle_logs')
        .select('''
        cost_of_load,
        description,
        log_date,
        vehicles(VehicleNo),
        drivers(name)
      ''')
        .order('log_date', ascending: false);
    
    // Debug: Print the raw response to see data types
    print('Raw response: $response');
    
    return response.map((row) {
      // Create a safe copy with proper type conversion
      final safeRow = <String, dynamic>{
        'log_date': row['log_date']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'cost_of_load': _safeConvertToString(row['cost_of_load']),
        'vehicles': row['vehicles'],
        'drivers': row['drivers'],
      };
      
      return LogModal.fromMap(safeRow);
    }).toList();
  } catch (e) {
    print('Error fetching joined logs: $e');
    return [];
  }
}

// Helper method for safe conversion
String _safeConvertToString(dynamic value) {
  if (value == null) return '0';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is num) return value.toString();
  return value.toString();
}

  Future<void> addLog({
    required String date,
    required String vehicleNo,
    required String driverName,
    required double cost,
    required String description,
  }) async {
    try {
      final dynamic vehicleId;
      final dynamic driverId;
      print(vehicleNo);
      final vehicleres = await supabaseClient
          .from('vehicles')
          .select('id')
          .eq('VehicleNo', vehicleNo)
          .maybeSingle();
      if (vehicleres == null) {
        print("❌ No vehicle found with that number");
        return;
      } else {
        vehicleId = vehicleres['id'];
        print("✅ Vehicle ID: $vehicleId");
      }

      final driverres = await supabaseClient
          .from('drivers')
          .select('id')
          .eq('name', driverName)
          .maybeSingle();
      if (driverres != null) {
        driverId = driverres['id'];
      } else {
        print("❌ No driver found with that name");
        return;
      }

      final newLog = LogModal(
        date: date,
        vehicleNo: vehicleId.toString(),
        driverName: driverId.toString(),
        cost_of_load: cost,
        description: description,
      );
      await supabaseClient.from('vehicle_logs').insert(newLog.toMap());
    } catch (e) {
      print('Error adding new log: $e');
    }
  }
}
