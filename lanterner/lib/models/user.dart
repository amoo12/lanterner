import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String email;
  String password;
  String gender;
  String name;
  String dateOfBirth;
  Language nativeLanguage;
  Language targetLanguage;

  User({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
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
      dateOfBirth: data['dateOfBirth'],
      nativeLanguage: Language.fromMap(data['nativeLanguage']),
      targetLanguage: Language.fromMap(data['targetLanguage']),
    );
  }
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
  Map<String, dynamic> toMap(Language language) {
    return {
      'title': language.title,
      'code': language.code,
      'level': language.level,
      'isNative': language.isNative,
    };
  }
}
