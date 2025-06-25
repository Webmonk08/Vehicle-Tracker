import 'package:uuid/uuid.dart';

class Driver {
  final String id;
  final String name;
  final String PhoneNo;

  Driver({
    String? id,
    required this.name,
    required this.PhoneNo,
  }): id = id ?? const Uuid().v4();

  factory Driver.fromMap(Map<String, dynamic> map) => Driver(
        id: map['id'],
        name: map['name'] ?? "",
        PhoneNo: map['PhoneNo'] ?? "",
      );
  
  Map<String,dynamic> toMap() =>{
    'id' : id,
    'name': name,
    'PhoneNo': PhoneNo,
  };
}
