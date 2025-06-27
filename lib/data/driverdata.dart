import 'package:my_app/modals/DriverModal.dart';

import '../service/supabaseService.dart';

class Driverdata {
  final supabaseClient = SupabaseService.client;

  Future<List<Driver>> getDrivers() async {
    try {
      final List<Map<String, dynamic>> data = await supabaseClient
          .from('drivers')
          .select();
      print("Driver Data : $data");
      return data.map((item) => Driver.fromMap(item)).toList();
    } catch (e) {
      print('Supabase error: $e');
      return [];
    }
  }

  Future<void> addDriver(Driver vehicle) async {
    print(vehicle.toMap());
    await supabaseClient.from('drivers').insert(vehicle.toMap());
  }

  Future<void> deleteDriver(String id) async {
    print('Deleting vehicle with ID: $id');
    await supabaseClient.from('drivers').delete().eq('id', id);
  }

  Future<void> updateDriver(String id, Driver driver) async {
    await supabaseClient
        .from('drivers')
        .update({'PhoneNo': driver.PhoneNo, 'name': driver.name})
        .eq('id', id);
  }
}
//
