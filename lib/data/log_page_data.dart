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
      print('=== DEBUG INFO ===');
      print('_isFilterApplied: $isFilterApplied');
      print('startDate: $startDate');
      print('endDate: $endDate');
      print('driverName: $driverName');
      print('vehicleNo: $vehicleNo');

      var query = supabaseClient.from('vehicle_logs').select('''
            cost_of_load,
            description,
            log_date,
            vehicles(VehicleNo),
            drivers(name)
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
          query = query.filter('vehicles.VehicleNo', 'eq', vehicleNo);
        }

        // Apply driver filter only if driverName is provided
        if (driverName != null && driverName.isNotEmpty) {
          print('Applying driver filter: $driverName');
          query = query.filter('drivers.name', 'eq', driverName);
        }
      }

      // Execute query with common parameters
      final List<Map<String, dynamic>> response = await query
          .limit(30)
          .order('log_date', ascending: false);

      print('Response count: ${response.length}');

      // Print first few log_dates to see what's actually in the DB
      if (response.isNotEmpty) {
        print('Sample log_dates from response:');
        for (int i = 0; i < (response.length > 5 ? 5 : response.length); i++) {
          print('  ${i + 1}: ${response[i]}');
        }
      }

      return response.map((row) {
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
