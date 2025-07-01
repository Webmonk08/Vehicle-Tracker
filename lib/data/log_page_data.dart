import 'package:my_app/modals/log_Modal.dart';
import 'package:my_app/service/supabaseService.dart';

class LogPageData {
  final supabaseClient = SupabaseService.client;

  Future<List<String>> getDriverNames() async {
    try {
      final response = await supabaseClient.from('drivers').select('name');

      return (response as List).map((row) => row['name'] as String).toList();
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  Future<List<String>> getVehicleNumbers() async {
    try {
      final response = await supabaseClient
          .from('vehicles')
          .select('VehicleNo');

      final vehicles = (response as List)
          .map((row) => row['VehicleNo'].toString())
          .toList();
      return vehicles;
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  Future<List<LogModal>> getLogs(
    String? startDate,
    String? endDate,
    String? driverName,
    String? vehicleNo,
    bool isFilterApplied,
  ) async {
    try {
      

      var query = supabaseClient.from('vehicle_logs').select('''
            id,
            cost_of_load,
            description,
            log_date,
            vehicle_id,
            driver_id,
            vehicles!inner(VehicleNo),
            drivers!inner(name)
          ''');

      if (isFilterApplied) {
        // Apply date filters only if dates are provided
        if (startDate != null && startDate.isNotEmpty) {
          print('Applying start date filter: $startDate');
          query = query.gte('log_date', startDate);
        }
        if (endDate != null && endDate.isNotEmpty) {
          print('Applying end date filter: $endDate');
          query = query.lte('log_date', endDate);
        }

        // Apply vehicle filter only if vehicleNo is provided
        if (vehicleNo != null && vehicleNo.isNotEmpty) {
          print('Applying vehicle filter: $vehicleNo');
          query = query.eq('vehicles.VehicleNo', vehicleNo);
        }

        // Apply driver filter only if driverName is provided
        if (driverName != null && driverName.isNotEmpty) {
          print('Applying driver filter: $driverName');
          query = query.eq('drivers.name', driverName);
        }
      }

      // Execute query with common parameters
      final List<Map<String, dynamic>> response = await query
          .limit(30)
          .order('log_date', ascending: false);

      print('Response count: ${response.length}');

      // Print first few log_dates to see what's actually in the DB
      

      return response.map((row) {
        final safeRow = <String, dynamic>{
          'id': row['id'],
          'log_date': row['log_date']?.toString() ?? '',
          'description': row['description']?.toString() ?? '',
          'cost_of_load': _safeConvertToString(row['cost_of_load']),
          'vehicles': row['vehicles'],
          'drivers': row['drivers'],
        };

        for (var log in safeRow.values) {
        print("Log entry: $log");
      }
      print("");

        return LogModal.fromMap(safeRow);
      }).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Test method to check what dates exist in your database
  Future<void> testDateRange() async {
    try {
      final response = await supabaseClient
          .from('vehicle_logs')
          .select('log_date')
          .order('log_date', ascending: false)
          .limit(10);

      print('=== RECENT DATES IN DB ===');
      for (var row in response) {
        print('Date: ${row['log_date']}');
      }

      final oldestResponse = await supabaseClient
          .from('vehicle_logs')
          .select('log_date')
          .order('log_date', ascending: true)
          .limit(5);

      print('=== OLDEST DATES IN DB ===');
      for (var row in oldestResponse) {
        print('Date: ${row['log_date']}');
      }
    } catch (e) {
      print('Error testing date range: $e');
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

  Future<bool> addLog({
    required String date,
    required String vehicleNo,
    required String driverName,
    required double cost,
    required String description,
  }) async {
    try {
      String? vehicleId;
      String? driverId;

      print('Adding log for vehicle: $vehicleNo');

      // Get vehicle ID
      final vehicleRes = await supabaseClient
          .from('vehicles')
          .select('id')
          .eq('VehicleNo', vehicleNo)
          .maybeSingle();

      if (vehicleRes == null) {
        print("❌ No vehicle found with number: $vehicleNo");
        return false;
      } else {
        vehicleId = vehicleRes['id'];
      }

      // Get driver ID
      final driverRes = await supabaseClient
          .from('drivers')
          .select('id')
          .eq('name', driverName)
          .maybeSingle();

      if (driverRes == null) {
        print("❌ No driver found with name: $driverName");
        return false;
      } else {
        driverId = driverRes['id'];
      }

      // Insert the log
      final logData = {
        'log_date': date,
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'cost_of_load': cost,
        'description': description,
      };

      await supabaseClient.from('vehicle_logs').insert(logData);
      print('✅ Log added successfully');
      return true;
    } catch (e) {
      print('❌ Error adding new log: $e');
      return false;
    }
  }

  Future<bool> updateLog({
    required String logId,
    required String date,
    required String vehicleNo,
    required String driverName,
    required double cost,
    required String description,
  }) async {
    try {
      String? vehicleId;
      String? driverId;

      print('Updating log with ID: $logId');

      // Get vehicle ID
      final vehicleRes = await supabaseClient
          .from('vehicles')
          .select('id')
          .eq('VehicleNo', vehicleNo)
          .maybeSingle();
      print("object");
      if (vehicleRes == null) {
        print("❌ No vehicle found with number: $vehicleNo");
        return false;
      } else {
        vehicleId = vehicleRes['id'];
        print("Vehicle $vehicleId");
      }

      // Get driver ID
      final driverRes = await supabaseClient
          .from('drivers')
          .select('id')
          .eq('name', driverName)
          .maybeSingle();

      if (driverRes == null) {
        print("❌ No driver found with name: $driverName");
        return false;
      } else {
        driverId = driverRes['id'];
      }

      // Update the log
      final logData = {
        'log_date': date,
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'cost_of_load': cost,
        'description': description,
      };

      await supabaseClient
          .from('vehicle_logs')
          .update(logData)
          .eq('id', logId);
      print(logData);
      print('✅ Log updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating log: $e');
      return false;
    }
  }

  Future<bool> deleteLog(String logId) async {
    try {

      await supabaseClient
          .from('vehicle_logs')
          .delete()
          .eq('id', logId);

      print('✅ Log deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting log: $e');
      return false;
    }
  }
}