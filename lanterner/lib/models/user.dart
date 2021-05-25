import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String email;
  String password;
  String gender;
  String name;
  String photoUrl;
  String dateOfBirth;
  int followers;
  int following;
  int postsCount;
  Language nativeLanguage;
  Language targetLanguage;
  List searchOptions;

  User({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.followers,
    this.following,
    this.postsCount,
    this.nativeLanguage,
    this.targetLanguage,
    this.searchOptions,
  });

  User.signup({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.followers,
    this.following,
    this.postsCount,
    this.nativeLanguage,
    this.targetLanguage,
  });

  factory User.fromMap(Map<dynamic, dynamic> data) {
    return User(
      uid: data['uid'],
      email: data['email'],
      password: data['password'],
      gender: data['gender'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      dateOfBirth: data['dateOfBirth'],
      followers: data['followers'],
      following: data['following'],
      postsCount: data['postsCount'],
      searchOptions: data['searchOptions'],
      nativeLanguage: Language.fromMap(data['nativeLanguage']),
      targetLanguage: Language.fromMap(data['targetLanguage']),
    );
  }

  factory User.fromSnapShot(DocumentSnapshot doc) {
    Map data = doc.data();
    return User(
      uid: doc.id,
      email: data['email'],
      password: data['password'],
      gender: data['gender'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      dateOfBirth: data['dateOfBirth'],
      followers: data['followers'],
      following: data['following'],
      postsCount: data['postsCount'],
      searchOptions: data['searchOptions'],
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
      'followers': followers ?? 0,
      'following': following ?? 0,
      'postsCount': postsCount ?? 0,
      'searchOptions': searchOptions,
      'nativeLanguage': nativeLanguage.toMap(),
      'targetLanguage': targetLanguage.toMap(),
    };
  }

  setSearchParameters() {
    List<String> searchOptions = [];
    String temp = "";
    for (int i = 0; i < this.name.length; i++) {
      temp = temp + this.name[i];
      searchOptions.add(temp);
    }
    this.searchOptions = searchOptions;
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
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'level': level,
      'isNative': isNative,
    };
  }
}
