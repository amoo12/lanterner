import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/widgets/buttons.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:smart_select/smart_select.dart';

import 'dart:math' as math;

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  PageController pageController;
  String fullName;
  String email;
  String password;
  String error;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: pageIndex, keepPage: true);
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

  _create(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 600), curve: Curves.easeInOutExpo);
    setState(() {});
  }

  String value = 'flutter';
  List<S2Choice<String>> languages = [
    S2Choice<String>(value: 'ion', title: 'Ionic'),
    S2Choice<String>(value: 'flu', title: 'Flutter'),
    S2Choice<String>(value: 'rea', title: 'React Native'),
    S2Choice<String>(value: 'rela', title: 'React Native'),
    S2Choice<String>(value: 'reja', title: 'React Native'),
    S2Choice<String>(value: 're;a', title: 'Reac2t Native'),
    S2Choice<String>(value: 'rfea', title: 'Reawct Native'),
    S2Choice<String>(value: 'raaea', title: 'Refsact Native'),
    S2Choice<String>(value: 'reaa', title: 'React Naftive'),
    S2Choice<String>(value: 'rcea', title: 'React Native'),
    S2Choice<String>(value: 'reha', title: 'Refact Native'),
  ];
  List<S2Choice<String>> levels = [
    S2Choice<String>(value: '1', title: '1'),
    S2Choice<String>(value: '2', title: '2'),
    S2Choice<String>(value: '3', title: '3'),
    S2Choice<String>(value: '4', title: '4'),
    S2Choice<String>(value: '5', title: '5'),
  ];

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
                      physics: NeverScrollableScrollPhysics(),
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
                                          onPressed: () =>
                                              _create(pageIndex + 1)),
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
                        Container(
                          height: _size.height * 0.9,
                          child: Column(
                            // mainAxisAlignment:,
                            children: [
                              //select Native language
                              Container(
                                height: _size.height * 0.65,
                                child: Column(
                                  children: [
                                    SmartSelect<String>.single(
                                        title: 'Native Language',
                                        placeholder: 'selecet',
                                        tileBuilder: (context, state) {
                                          return S2Tile.fromState(
                                            state,
                                            title: Text('Native Language',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          );
                                        },
                                        choiceHeaderStyle: S2ChoiceHeaderStyle(
                                            textStyle:
                                                TextStyle(color: Colors.white)),
                                        modalFilterHint: 'search languages',
                                        choiceStyle: S2ChoiceStyle(
                                          activeColor:
                                              Theme.of(context).accentColor,
                                          color: Colors.grey,
                                          titleStyle:
                                              TextStyle(color: Colors.white),
                                        ),
                                        modalType: S2ModalType.popupDialog,
                                        modalHeaderStyle: S2ModalHeaderStyle(
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 0,
                                        ),
                                        modalStyle: S2ModalStyle(
                                            backgroundColor:
                                                Theme.of(context).cardColor),
                                        modalFilter: true,
                                        value: value,
                                        choiceItems: languages,
                                        onChange: (state) => setState(
                                            () => value = state.value)),

                                    Divider(
                                      thickness: 1.5,
                                    ),
                                    // Native language level selector
                                    SmartSelect<String>.single(
                                      title: 'Level',
                                      tileBuilder: (context, state) {
                                        return S2Tile.fromState(
                                          state,
                                          title: Text('Level',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        );
                                      },
                                      placeholder: 'selecet',
                                      // modalConfig: S2ModalStyle(),
                                      modalType: S2ModalType.bottomSheet,
                                      modalHeaderStyle: S2ModalHeaderStyle(
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 1),
                                      modalStyle: S2ModalStyle(
                                        backgroundColor:
                                            Theme.of(context).cardColor,
                                      ),
                                      value: value,
                                      choiceItems: levels,
                                      onChange: (state) =>
                                          setState(() => value = state.value),
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
                                          text: 'Next',
                                          onPressed: () =>
                                              _create(pageIndex + 1)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Center(child: Text("step 3")),
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
