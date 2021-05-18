import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String email;
  String password;
  String gender;
  String name;
  String photoUrl;
  String dateOfBirth;
  Language nativeLanguage;
  Language targetLanguage;

  User({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.nativeLanguage,
    this.targetLanguage,
  });

  User.signup({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.nativeLanguage,
    this.targetLanguage,
  });

  factory User.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return User(
      uid: doc.id,
      email: data['email'],
      password: data['password'],
      gender: data['gender'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      dateOfBirth: data['dateOfBirth'],
      nativeLanguage: Language.fromMap(data['nativeLanguage']),
      targetLanguage: Language.fromMap(data['targetLanguage']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'gender': gender,
      'name': name,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth,
      'nativeLanguage': nativeLanguage.toMap(),
      'targetLanguage': targetLanguage.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

class Language {
  String title;
  String code;
  String level;
  bool isNative;

  Language({this.code, this.isNative, this.level, this.title});

  factory Language.fromMap(Map<dynamic, dynamic> data) {
    return Language(
      title: data['title'],
      code: data['code'],
      level: data['level'],
      isNative: data['isNative'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'level': level,
      'isNative': isNative,
    };
  }
}
