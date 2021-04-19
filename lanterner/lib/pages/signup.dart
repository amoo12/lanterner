import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/widgets/buttons.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/languagesList.dart';
import 'package:lanterner/widgets/radioButtons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smart_select/smart_select.dart';

import 'dart:math' as math;

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  PageController pageController;
  String fullName = '';
  String email = '';
  String password = '';
  String error;
  int pageIndex;

  double height = 100;
  double width = 100;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, keepPage: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      print('saved');
      form.save();
    }
  }

  _goToLogin() {
    Navigator.popAndPushNamed(context, '/login');
  }

  onSavedEmail(String value) {
    if (!EmailValidator.validate(value)) {
      error = "enter a valid email";
      setState(() {});
    } else {
      email = value;
      error = null;
      setState(() {});
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

  String nativeLanguage = '';
  String targetLanguage = '';
  String level = '';

  String gender = '';

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      // physics: NeverScrollableScrollPhysics(),
                      controller: pageController,
                      children: [
                        Container(
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
                                                fontFamily: 'OpenSans-Regular',
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
                                          ),
                                          TextFormFieldWidget(
                                            lableText: 'Email',
                                            onSaved: onSavedEmail,
                                            validatorMessage: 'Enter an email',
                                          ),
                                          TextFormFieldWidget(
                                            lableText: 'Password',
                                            onSaved: onSavedPassword,
                                            validatorMessage:
                                                'Enter a password',
                                            obscureText: true,
                                          ),
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
                                            // _submit();
                                            // if (fullName == '' ||
                                            //     email == '' ||
                                            //     password == '') {
                                            // error = 'please fill all fields';
                                            // SnackBar registrationBar =
                                            //     SnackBar(
                                            //   behavior:
                                            //       SnackBarBehavior.floating,
                                            //   margin: EdgeInsets.only(
                                            //       bottom: _size.height * 0.15,
                                            //       left: _size.width * 0.09,
                                            //       right: _size.width * 0.09),
                                            //   content: Text(
                                            //     'please fill all fields',
                                            //   ),
                                            // );
                                            // Scaffold.of(context).showSnackBar(
                                            //     registrationBar);
                                            // } else {
                                            next();
                                            // }
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
                          size: _size,
                          nativeLanguage: nativeLanguage,
                          targetLanguage: targetLanguage,
                          level: level,
                          next: next,
                        ),
                        Container(
                          height: _size.height * 0.9,
                          width: _size.width * 0.9,
                          child: Column(
                            children: [
                              Container(
                                  height: _size.height * 0.5,
                                  child: CustomRadio(gender)),
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
  }
}

class SignupStep2 extends StatefulWidget {
  SignupStep2({
    Key key,
    @required Size size,
    @required this.nativeLanguage,
    @required this.targetLanguage,
    @required this.level,
    @required this.next,
  })  : _size = size,
        super(key: key);

  final Size _size;
  String nativeLanguage;
  String targetLanguage;
  String level;
  Function next;

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        height: widget._size.height * 0.9,
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
                          print(nativeLanguage);
                          print(targetLanguage);
                          print(level);
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
                            Scaffold.of(context).showSnackBar(registrationBar);
                          } else {
                            widget.nativeLanguage = nativeLanguage;
                            widget.targetLanguage = targetLanguage;
                            widget.level = level;

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
