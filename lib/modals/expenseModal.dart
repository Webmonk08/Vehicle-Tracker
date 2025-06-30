class Expensemodal {
  final String vehicleNo;
  final String? description;
  final String date;
  final String expense;

  Expensemodal({
    required this.vehicleNo,
    this.description,
    required this.date,
    required this.expense,
  });

  // Factory constructor from JSON  
  factory Expensemodal.fromMap(Map<String, dynamic> map) {
    print(map['vehicels']);
    return Expensemodal(
      // Access VehicleNo from the nested vehicles object
      vehicleNo: map['vehicles']?['VehicleNo']?.toString() ?? "",
      description: map['description'],
      date: map['date'],
      expense: map['expense'].toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toMap() {
    return {
      'vehicleNo': vehicleNo,
      'description': description,
      'date': date,
      'expense': expense,
    };
  }
}