class StaffModel {
  final int id;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String phonenumber;
  final DateTime createdAt;
  final String address;

  StaffModel({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phonenumber,
    required this.createdAt,
    required this.address,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    List<int> createdAtList = List<int>.from(json['createdAt'] ?? []);
    return StaffModel(
      id: json['id'],
      username: json['username'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      createdAt: createdAtList.length >= 6
          ? DateTime.utc(
              createdAtList[0],
              createdAtList[1],
              createdAtList[2],
              createdAtList[3],
              createdAtList[4],
              createdAtList[5],
              (createdAtList[6] / 1000000).round(),
            )
          : DateTime.now(),
      address: json['address'] ?? '',
    );
  }
}
