import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));
String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String? email;
  final String usrName;
  final String password;
  final int? age;
  final double? weight;
  final double? height;

  Users({
    this.usrId,
    this.fullName,
    this.email,
    required this.usrName,
    required this.password,
    this.age,
    this.weight,
    this.height,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrId"],
    fullName: json["fullName"],
    email: json["email"],
    usrName: json["usrName"],
    password: json["usrPassword"],
    age: json["age"],
    weight: json["weight"]?.toDouble(),
    height: json["height"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "usrId": usrId,
    "fullName": fullName,
    "email": email,
    "usrName": usrName,
    "usrPassword": password,
    "age": age,
    "weight": weight,
    "height": height,
  };
}