class LogModal {
  final String date;
  final String vehicleNo;
  final String driverName;
  final double cost_of_load; // Changed to double
  final String description;

  LogModal({
    required this.date,
    required this.vehicleNo,
    required this.driverName,
    required this.cost_of_load,
    required this.description,
  });

  factory LogModal.fromMap(Map<String, dynamic> map) {
    return LogModal(
      date: map['log_date']?.toString() ?? '',
      description: map['description']?.toString() ?? '',

      // Handle cost_of_load - convert int/double to double
      cost_of_load: _parseToDouble(map['cost_of_load']),

      // Handle nested objects
      vehicleNo: map['vehicles'] != null
          ? (map['vehicles']['VehicleNo']?.toString() ?? '')
          : '',
      driverName: map['drivers'] != null
          ? (map['drivers']['name']?.toString() ?? '')
          : '',
    );
  }

  // Helper method to safely convert to double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'log_date': date,
      'vehicle_id': vehicleNo,
      'driver_id': driverName,
      'cost_of_load': cost_of_load,
      'description': description,
    };
  }

  // Helper getter for displaying cost as formatted string
  String get formattedCost => cost_of_load.toStringAsFixed(2);
}
