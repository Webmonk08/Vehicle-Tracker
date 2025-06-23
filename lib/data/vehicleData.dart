import '../service/supabaseService.dart';
import '../modals/vehiclemodal.dart'; 


class Vehicledata {

  final client = SupabaseService.client;

  Future<List<Vehicle>> getVehicles() async {
    final response = await client.from('vehicles').select();
    if (response.error != null) {
      throw Exception('Failed to load vehicles: ${response.error!.message}');
    }
    else{
      return (response.data as List)
          .map((item) => Vehicle.fromMap(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> addvehicle(Vehicle vehicle) async{
    await client.from('vehicles').insert(vehicle.toMap()).execute();
  }

  Future<void> deleteVehicle(String id) async {
    await client.from('vehicles').delete().eq('id',id);
  }

  Future<void> UpdateVehicle(String id , Vehicle vehicle) async{
    
    await client.from('vehicles').update({
      'VehicleNo': vehicle.vehicleNo,
    })
    .eq('id',id);
  }
}



