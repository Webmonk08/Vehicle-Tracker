import 'package:uuid/uuid.dart';

class Vehicle {
  final String id;
  final String vehicleNo;

  Vehicle({
    String? id, // optional for auto-gen
    required this.vehicleNo,
  }) : id = id ?? const Uuid().v4(); // generate only if not passed

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        id: map['id'], // read from Supabase or map
        vehicleNo: map['vehicle_no'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_no': vehicleNo,
      };
}
