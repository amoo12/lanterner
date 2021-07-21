import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/services/auth_service.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/buttons.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/customToast.dart';
import 'package:lanterner/widgets/languagesList.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:lanterner/widgets/radioButtons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';

import 'dart:math' as math;

import '../../models/user.dart';
// import '../models/user.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  PageController pageController;
  UploadPhoto uploadPhoto;
  DatabaseService db = DatabaseService();
  String fullName = '';
  String email = '';
  String password = '';
  String error;
  int pageIndex;
  DateTime selectedDate = DateTime.now();

  User _user = User.signup();

  bool isSelected = false;

  double height = 100;
  double width = 100;

  String imageError = '';
  FToast fToast;
  AuthenticationService _auth;

  @override
  void initState() {
    uploadPhoto = UploadPhoto();
    super.initState();
    pageController = PageController(initialPage: 0, keepPage: true);
    _auth = context.read(authServicesProvider);
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

// validates the input for the first create account page (naem, email, password) id everything next
  step1Submit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      if (onSavedEmail(emailController.text.trim())) {
        if (passwordController.text.trim().length < 6) {
          error = 'passsword must be at least 6 characters';
        } else {
          form.save();
          _user.email = emailController.text.trim();
          _user.password = passwordController.text.trim();
          _user.name = nameController.text.trim();

          final isRegistered =
              await _auth.isAlreadyRegistered(emailController.text.trim());
          if (isRegistered == false) {
            showToast(fToast, 'email Already registered');
          } else {
            next();
          }
        }
      }
    }
  }

  //callback to track gender changes in the radion widget
  void genderChanged(String value) {
    gender = value;
  }

  //shows the date picker
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        isSelected = true;
      });
  }

  bool onSavedEmail(String value) {
    if (!EmailValidator.validate(value)) {
      error = "enter a valid email";
      setState(() {});
      return false;
    } else {
      email = value;
      error = null;
      setState(() {});
      return true;
    }
  }

  onSavedPassword(String value) {
    password = value;
  }

  onSavedFullName(String value) {
    fullName = value;
  }

  //moves page view to next page
  next() {
    pageController.nextPage(
        duration: Duration(milliseconds: 600), curve: Curves.easeInOutExpo);
  }

  createAcount(BuildContext context) async {
    await _auth.signUp(_user);
    
    next();
    Navigator.pop(context);
  }

  uploadImage(String uid) async {
    String photoUrl;
    await uploadPhoto.compressImage(uid);
    photoUrl = await uploadPhoto.uploadImage(
        imageFile: uploadPhoto.file, id: uid, folder: 'profile');
    await db.updateProfilePicture(uid, photoUrl);
  }

  String nativeLanguage = '';
  String targetLanguage = '';
  String level = '';

  String gender = '';

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Consumer(builder: (context, watch, child) {
      final _authState = watch(authStateProvider);
      return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            elevation: 0,
            leading: Transform.rotate(
              angle: 45 * math.pi / 180,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30,
                ),
                // tooltip: 'Show Snackbar',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            child: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Container(
                    height: _size.height * 0.9,
                    width: _size.width,
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: pageController,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: _size.height * 0.65,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: _size.height * 0.1,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Let's setup your account ",
                                              style: TextStyle(
                                                  fontFamily:
                                                      'OpenSans-Regular',
                                                  fontSize: 25,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextFormFieldWidget(
                                              lableText: 'Name',
                                              onSaved: onSavedFullName,
                                              validatorMessage: 'Enter a name',
                                              controller: nameController,
                                            ),
                                            TextFormFieldWidget(
                                              lableText: 'Email',
                                              onSaved: onSavedEmail,
                                              validatorMessage:
                                                  'Enter an email',
                                              controller: emailController,
                                            ),
                                            TextFormFieldWidget(
                                              lableText: 'Password',
                                              onSaved: onSavedPassword,
                                              validatorMessage:
                                                  'Enter a password',
                                              controller: passwordController,
                                              obscureText: true,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              error != null ? '$error' : '',
                                              style: TextStyle(
                                                color: Colors.redAccent[400],
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: _size.height * 0.20,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ButtonWidget(
                                            context: context,
                                            text: 'Create an Acount',
                                            onPressed: () {
                                              step1Submit();
                                            }),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SignupStep2(
                            user: _user,
                            size: _size,
                            nativeLanguage: nativeLanguage,
                            targetLanguage: targetLanguage,
                            level: level,
                            next: next,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            height: _size.height * 0.9,
                            width: _size.width * 0.9,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: _size.height * 0.65,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        Container(
                                            // color:
                                            // Theme.of(context).backgroundColor,
                                            height: _size.height * 0.3,
                                            width: _size.width * 0.9,
                                            child: CustomRadio(genderChanged)),
                                        Text(
                                          'Date of birth',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        GestureDetector(
                                          onTap: () => _selectDate(context),
                                          child: Container(
                                            child: Container(
                                              height: 150,
                                              margin: EdgeInsets.all(15.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    height: 100,
                                                    width: 100,
                                                    curve: Curves.ease,
                                                    child: Center(
                                                        child: Icon(
                                                      Icons.cake_outlined,
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.grey,
                                                      size:
                                                          isSelected ? 32 : 24,
                                                    )),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                          width: 1.0,
                                                          color: isSelected
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.grey),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              const Radius
                                                                      .circular(
                                                                  8.0)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: isSelected
                                                              ? Colors.black
                                                                  .withOpacity(
                                                                      0.2)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.0),
                                                          spreadRadius: 4,
                                                          blurRadius: 3,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10.0),
                                                    child: Text(
                                                      isSelected
                                                          ? selectedDate.day
                                                                  .toString() +
                                                              ' - ' +
                                                              selectedDate.month
                                                                  .toString() +
                                                              ' - ' +
                                                              selectedDate.year
                                                                  .toString()
                                                          : '',
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // FloatingActionButton(
                                        //     onPressed: () => _selectDate(context),
                                        //     child: Icon(Icons.cake)
                                        //     // color: Colors.greenAccent,
                                        //     )
                                      ],
                                    )),
                                Container(
                                  height: _size.height * 0.20,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ButtonWidget(
                                            context: context,
                                            text: "Next",
                                            onPressed: () async {
                                              if (gender == '' || !isSelected) {
                                                SnackBar registrationBar =
                                                    SnackBar(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          _size.height * 0.15,
                                                      left: _size.width * 0.09,
                                                      right:
                                                          _size.width * 0.09),
                                                  content: Text(
                                                    'please fill all fields',
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        registrationBar);
                                              } else {
                                                customProgressIdicator(context);
                                                _user.gender = gender;
                                                _user.dateOfBirth =
                                                    selectedDate.toString();
                                                createAcount(context);
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            height: _size.height * 0.9,
                            width: _size.width * 0.9,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: _size.height * 0.65,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Last step',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        Text(
                                          'Upload a profile photo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2
                                              .copyWith(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SimpleDialog(
                                                  title: Text("Upload image"),
                                                  children: <Widget>[
                                                    SimpleDialogOption(
                                                        child: Text(
                                                            "Photo with Camera"),
                                                        onPressed: () async {
                                                          await uploadPhoto
                                                              .handleTakePhoto(
                                                                  context);
                                                          setState(() {});
                                                        }),
                                                    SimpleDialogOption(
                                                        child: Text(
                                                            "Image from Gallery"),
                                                        onPressed: () async {
                                                          await uploadPhoto
                                                              .handleChooseFromGallery(
                                                                  context);
                                                          setState(() {});
                                                        }),
                                                    SimpleDialogOption(
                                                      child: Text("Cancel"),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: uploadPhoto.file == null
                                              ? Container(
                                                  child: Container(
                                                    height: 215,
                                                    margin:
                                                        EdgeInsets.all(15.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: <Widget>[
                                                        AnimatedContainer(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          height: 180,
                                                          width: 180,
                                                          curve: Curves.ease,
                                                          child: Center(
                                                              child: Icon(
                                                            Icons.add,
                                                            color: Colors.grey,
                                                            size: 32,
                                                          )),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            border: Border.all(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        8.0)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          imageError,
                                                          style: TextStyle(
                                                              color: Colors
                                                                      .redAccent[
                                                                  400]),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  // alignment: Alignment.centerLeft,
                                                  height: 175.0,
                                                  width: 175.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        width: 0.5,
                                                      )),
                                                  // width: MediaQuery.of(context).size.width * 0.8,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Center(
                                                        child: Container(
                                                          height: 170.0,
                                                          width: 170.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: FileImage(
                                                                  uploadPhoto
                                                                      .file),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                          color: Colors.grey[50]
                                                              .withOpacity(0.8),
                                                          icon: Icon(
                                                              Icons.cancel),
                                                          onPressed: () {
                                                            setState(() {
                                                              uploadPhoto
                                                                  .clearImage();
                                                            });
                                                          })
                                                    ],
                                                  ),
                                                ),
                                        ),
                                        // FloatingActionButton(
                                        //     onPressed: () => _selectDate(context),
                                        //     child: Icon(Icons.cake)
                                        //     // color: Colors.greenAccent,
                                        //     )
                                      ],
                                    )),
                                Container(
                                  height: _size.height * 0.20,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ButtonWidget(
                                            context: context,
                                            text: "Skip",
                                            buttonType: 2,
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            }),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ButtonWidget(
                                            context: context,
                                            text: "Let's Go",
                                            onPressed: () async {
                                              if (uploadPhoto.file != null) {
                                                customProgressIdicator(context);
                                                await uploadImage(
                                                    _authState.data.value.uid);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              } else {
                                                setState(() {
                                                  imageError =
                                                      'Please select a photo';
                                                });
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
    });
  }
}

//ignore: must_be_immutable
class SignupStep2 extends StatefulWidget {
  SignupStep2({
    Key key,
    @required Size size,
    @required this.nativeLanguage,
    @required this.targetLanguage,
    @required this.level,
    @required this.next,
    @required this.user,
  })  : _size = size,
        super(key: key);

  final Size _size;
  String nativeLanguage;
  String targetLanguage;
  String level;
  Function next;
  final User user;

  @override
  _SignupStep2State createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  String nativeLanguage = ''; //target language value i.e ar
  String nTitle =
      ''; //target language title i.e Arabic (acts as placeholder for the choice tile)
  String targetLanguage = ''; //target language value i.e ar
  String tTitle =
      ''; //target language title i.e Arabic (acts as placeholder for the choice tile)
  String level = '';
  String lTitle = '';

  GlobalKey<S2SingleState<String>> _nativeSelectKey =
      GlobalKey<S2SingleState<String>>();
  GlobalKey<S2SingleState<String>> _targetSelectKey =
      GlobalKey<S2SingleState<String>>();
  GlobalKey<S2SingleState<String>> _levelSelectKey =
      GlobalKey<S2SingleState<String>>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        height: widget._size.height * 0.9,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          // mainAxisAlignment:,
          children: [
            Container(
              padding: EdgeInsets.only(top: 20),
              height: widget._size.height * 0.65,
              child: Column(
                children: [
                  Text(
                    'Languages',
                    style: TextStyle(fontSize: 20),
                  ),
                  //select Native language
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Native',
                          style: TextStyle(
                              // color: Colors.white,
                              // fontSize: 20,
                              ),
                        ),
                        SmartSelect<String>.single(
                            key: _nativeSelectKey,
                            title: 'Native Language',
                            placeholder: nTitle == '' ? 'select' : nTitle,
                            tileBuilder: (context, state) {
                              return S2Tile.fromState(
                                state,
                                title: Text('Native Language',
                                    style: TextStyle(color: Colors.white)),
                              );
                            },
                            modalFilterHint: 'search languages',
                            choiceHeaderStyle: S2ChoiceHeaderStyle(
                                textStyle: TextStyle(color: Colors.white)),
                            choiceBuilder: (context, choice, searchText) {
                              return ListTile(
                                leading: Text(
                                  choice.title,
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: choice.title == nTitle
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                                // trailing: ,
                                onTap: () {
                                  nativeLanguage = choice.value;
                                  nTitle = choice.title;
                                  setState(() {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) =>
                                            _nativeSelectKey.currentState
                                                .closeModal());
                                  });
                                },
                              );
                            },
                            modalHeaderStyle: S2ModalHeaderStyle(
                              actionsIconTheme:
                                  IconThemeData(color: Colors.white),
                              iconTheme: IconThemeData(color: Colors.white),
                              textStyle: TextStyle(color: Colors.white),
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 0,
                            ),
                            modalStyle: S2ModalStyle(
                                backgroundColor: Theme.of(context).cardColor),
                            modalFilter: true,
                            modalFilterAuto: true,
                            value: nativeLanguage,
                            choiceItems: LanguagesList.languages,
                            onChange: (state) => setState(() {})),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    thickness: 1.5,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //select target language
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target'),
                        SmartSelect<String>.single(
                          key: _targetSelectKey,
                          placeholder: tTitle == '' ? 'select' : tTitle,
                          title: 'Language',
                          tileBuilder: (context, state) {
                            return S2Tile.fromState(
                              state,
                              leading: Text('Language',
                                  style: TextStyle(color: Colors.white)),
                              title: Center(
                                child: Text(level == '' ? '' : '($level)',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                          modalFilterHint: 'search languages',
                          choiceBuilder: (context, choice, searchText) {
                            return ListTile(
                              leading: Text(
                                choice.title,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: choice.title == tTitle
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : null,
                              onTap: () {
                                targetLanguage = choice.value;
                                tTitle = choice.title;
                                setState(() {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _targetSelectKey.currentState
                                          .closeModal());
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _levelSelectKey.currentState
                                          .showModal());
                                });
                              },
                            );
                          },
                          choiceHeaderStyle: S2ChoiceHeaderStyle(
                              textStyle: TextStyle(color: Colors.white)),
                          modalHeaderStyle: S2ModalHeaderStyle(
                            actionsIconTheme:
                                IconThemeData(color: Colors.white),
                            iconTheme: IconThemeData(color: Colors.white),
                            textStyle: TextStyle(color: Colors.white),
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 0,
                          ),
                          modalStyle: S2ModalStyle(
                              backgroundColor: Theme.of(context).cardColor),
                          modalFilter: true,
                          modalFilterAuto: true,
                          value: targetLanguage,
                          choiceItems: LanguagesList.languages,
                          onChange: (state) {
                            setState(() {});
                          },
                        ),
                        // Native language level selector
                        SmartSelect<String>.single(
                          key: _levelSelectKey,
                          title: 'Level',
                          tileBuilder: (context, state) {
                            return Container();
                          },
                          choiceBuilder: (context, choice, searchText) {
                            return ListTile(
                              leading: Text(
                                choice.title,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: choice.title == lTitle
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : null,
                              onTap: () {
                                level = choice.value;
                                lTitle = choice.title;
                                setState(() {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _levelSelectKey.currentState
                                          .closeModal());
                                });
                              },
                            );
                          },
                          choiceHeaderStyle: S2ChoiceHeaderStyle(
                              textStyle: TextStyle(color: Colors.white)),
                          modalHeaderStyle: S2ModalHeaderStyle(
                            textStyle: TextStyle(color: Colors.white),
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 0,
                          ),
                          modalStyle: S2ModalStyle(
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          modalConfig: S2ModalConfig(
                            barrierDismissible: false,
                          ),
                          modalType: S2ModalType.popupDialog,
                          value: level,
                          choiceItems: LanguagesList.levels,
                          onChange: (state) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: widget._size.height * 0.20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ButtonWidget(
                        context: context,
                        text: 'Next',
                        onPressed: () async {
                          if (nativeLanguage == '' ||
                              targetLanguage == '' ||
                              level == '') {
                            // error = 'please fill all fields';
                            SnackBar registrationBar = SnackBar(
                              duration: Duration(milliseconds: 300),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                  bottom: widget._size.height * 0.15,
                                  left: widget._size.width * 0.09,
                                  right: widget._size.width * 0.09),
                              content: Text(
                                'please fill all fields',
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(registrationBar);
                          } else {
                            widget.user.nativeLanguage = Language(
                                code: nativeLanguage,
                                title: nTitle,
                                isNative: true);

                            widget.user.targetLanguage = Language(
                              code: targetLanguage,
                              title: tTitle,
                              isNative: false,
                              level: level,
                            );

                            // widget.nativeLanguage = nativeLanguage;
                            // widget.targetLanguage = targetLanguage;
                            // widget.level = level;

                            widget.next();
                          }
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
