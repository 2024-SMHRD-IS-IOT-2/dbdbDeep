
import 'dart:convert';

List<MemberModel> memberModelFromJson(String str) => List<MemberModel>.from(json.decode(str).map((x) => MemberModel.fromJson(x)));

String memberModelToJson(List<MemberModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MemberModel {
  String userId;
  String userPw;
  String userName;
  String userAddr;
  String userTel;
  DateTime userBirth;
  DateTime joinedAt;

  MemberModel({
    required this.userId,
    required this.userPw,
    required this.userName,
    required this.userAddr,
    required this.userTel,
    required this.userBirth,
    required this.joinedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
    userId: json["USER_ID"],
    userPw: json["USER_PW"],
    userName: json["USER_NAME"],
    userAddr: json["USER_ADDR"],
    userTel: json["USER_TEL"],
    userBirth: DateTime.parse(json["USER_BIRTH"]),
    joinedAt: DateTime.parse(json["JOINED_AT"]),
  );

  Map<String, dynamic> toJson() => {
    "USER_ID": userId,
    "USER_PW": userPw,
    "USER_NAME": userName,
    "USER_ADDR": userAddr,
    "USER_TEL": userTel,
    "USER_BIRTH": "${userBirth.year.toString().padLeft(4, '0')}-${userBirth.month.toString().padLeft(2, '0')}-${userBirth.day.toString().padLeft(2, '0')}",
    "JOINED_AT": joinedAt.toIso8601String(),
  };
}
