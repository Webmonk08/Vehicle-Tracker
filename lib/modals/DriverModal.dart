
class Driver {
  final String id;
  final String name;
  final String PhoneNo;

  Driver({
    required this.id,
    required this.name,
    required this.PhoneNo,
  });

  factory Driver.fromMap(Map<String, dynamic> map) => Driver(
        id: map['id'] ?? "",
        name: map['name'] ?? "",
        PhoneNo: map['PhoneNo'] ?? "",
      );
  
  Map<String,dynamic> toMap() =>{
    'id' : id,
    'name': name,
    'PhoneNo': PhoneNo,
  };
}
