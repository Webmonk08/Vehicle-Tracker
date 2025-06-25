import '../service/supabaseService.dart';
import 'package:my_app/modals/vehicleModal.dart';

class Vehicledata {
  final supabaseClient = SupabaseService.client;

Future<List<Vehicle>> getVehicles() async {
  try {
    final List<Map<String, dynamic>> data = await supabaseClient
        .from('vehicles')
        .select();
    print(data);
    return data.map((item) => Vehicle.fromMap(item)).toList();
  } catch (e) {
    print('Supabase error: $e');
    return [];
  }
}

  Future<void> addvehicle(Vehicle vehicle) async {
    print(vehicle.toMap());
    await supabaseClient.from('vehicles').insert(vehicle.toMap());
  }

  Future<void> deleteVehicle(String id) async {
    print('Deleting vehicle with ID: $id');
    await supabaseClient.from('vehicles').delete().eq('id', id);
  }

  Future<void> updateVehicle(String id, Vehicle vehicle) async {
    await supabaseClient
        .from('vehicles')
        .update({'VehicleNo': vehicle.vehicleNo})
        .eq('id', id);
  }
}