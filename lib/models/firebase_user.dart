// To parse this JSON data, do
//
//     final firebaseUser = firebaseUserFromJson(jsonString);

import 'dart:convert';

FirebaseUser firebaseUserFromJson(String str) =>
    FirebaseUser.fromJson(json.decode(str));

String firebaseUserToJson(FirebaseUser data) => json.encode(data.toJson());

class FirebaseUser {
  FirebaseUser({
    this.number,
    this.profilePicUrl,
    this.name,
    this.id,
    this.email,
    this.token,
  });

  String? number;

  String? profilePicUrl;
  String? name;
  String? id;
  String? email;
  String? token;

  factory FirebaseUser.fromJson(Map<String, dynamic> json) => FirebaseUser(
        number: json["number"] == null ? null : json["number"],
        profilePicUrl:
            json["profile_Pic_URL"] == null ? null : json["profile_Pic_URL"],
        name: json["name"] == null ? null : json["name"],
        id: json["id"] == null ? null : json["id"],
        email: json["email"] == null ? null : json["email"],
        token: json["token"] == null ? null : json["token"],
      );

  Map<String, dynamic> toJson() => {
        "number": number == null ? null : number,
        "profile_Pic_URL": profilePicUrl == null ? null : profilePicUrl,
        "name": name == null ? null : name,
        "id": id == null ? null : id,
        "email": email == null ? null : email,
        "token": token == null ? null : token,
      };
}
