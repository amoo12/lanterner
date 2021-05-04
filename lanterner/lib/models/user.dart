class User {
  String uid;
  String email;
  String password;
  String gender;
  String name;
  String dateOfBirth;
  Language nativeLanguage;
  Language targetLanguage;

  User(
      {this.uid,
      this.email,
      this.password,
      this.gender,
      this.name,
      this.nativeLanguage});

  User.signup(
      {this.uid,
      this.email,
      this.password,
      this.gender,
      this.name,
      this.nativeLanguage});

  // void setEmail(String email) {
  //   this.email = email;
  // }

  // void setPassword(String password) {
  //   this.password = password;
  // }
}

class Language {
  String title;
  String code;
  String level;
  bool isNative;

  Language({this.code, this.isNative, this.level, this.title});
}
