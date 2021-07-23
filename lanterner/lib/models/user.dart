import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: add the following fields
// registrationDate: DateTime.now().toUtc(), //registertion date
// lastLoggedIn: DateTime.now().toUtc(), // lastLogged
// buildNumber: buildNumber, // no idea
// introSeen: false, // first time user or not - I think it should be set to fals after the first time.
class User {
  String uid;
  String email;
  String password;
  String gender;
  String name;
  String photoUrl;
  String dateOfBirth;
  String bio;
  int followers;
  int following;
  int postsCount;
  int translationsCount;
  int audioListened;
  Language nativeLanguage;
  Language targetLanguage;
  List searchOptions;
  bool admin;

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
    this.bio,
    this.admin,
    this.translationsCount,
    this.audioListened,
  });

  User.signup({
    this.uid,
    this.email,
    this.password,
    this.gender,
    this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.followers = 0,
    this.following = 0,
    this.postsCount = 0,
    this.nativeLanguage,
    this.targetLanguage,
    this.searchOptions,
    this.bio,
    this.admin = false,
    this.translationsCount = 0,
    this.audioListened = 0,
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
      bio: data['bio'],
      followers: data['followers'] ?? 0,
      following: data['following'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      searchOptions: data['searchOptions'],
      admin: data['admin'],
      translationsCount: data['translationsCount'] ?? 0,
      audioListened: data['audioListened'] ?? 0,
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
      bio: data['bio'],
      followers: data['followers'] ?? 0,
      following: data['following'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      searchOptions: data['searchOptions'],
      admin: data['admin'],
      translationsCount: data['translationsCount'] ?? 0,
      audioListened: data['audioListened'] ?? 0,
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
      'bio': bio,
      'followers': followers ?? 0,
      'following': following ?? 0,
      'postsCount': postsCount ?? 0,
      'searchOptions': searchOptions,
      'admin': admin,
      'translationsCount': translationsCount,
      'audioListened': audioListened,
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

  @override
  String toString() {
    return 'Language(title: $title, code: $code, level: $level, isNative: $isNative)';
  }
}
