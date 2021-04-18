import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
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
  String fullName = '';
  String email = '';
  String password = '';
  String error;
  int pageIndex;

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

  List<S2Choice<String>> languages = [
    S2Choice<String>(value: 'af', title: 'Afrikaans'),
    S2Choice<String>(value: 'sq', title: 'Albanian'),
    S2Choice<String>(value: 'am', title: 'Amharic'),
    S2Choice<String>(value: 'ar', title: 'Arabic'),
    S2Choice<String>(value: 'hy', title: 'Armenian'),
    S2Choice<String>(value: 'az', title: 'Azerbaijani'),
    S2Choice<String>(value: 'eu', title: 'Basque'),
    S2Choice<String>(value: 'be', title: 'Belarusian'),
    S2Choice<String>(value: 'bn', title: 'Bengali'),
    S2Choice<String>(value: 'bs', title: 'Bosnian'),
    S2Choice<String>(value: 'bg', title: 'Bulgarian'),
    S2Choice<String>(value: 'ca', title: 'Catalan'),
    S2Choice<String>(value: 'ceb', title: 'Cebuano'),
    S2Choice<String>(value: 'zh', title: 'Chinese (Simplified)'),
    S2Choice<String>(value: 'zh-TW', title: 'Chinese (Traditional)'),
    S2Choice<String>(value: 'co', title: 'Corsican'),
    S2Choice<String>(value: 'hr', title: 'Croatian'),
    S2Choice<String>(value: 'cs', title: 'Czech'),
    S2Choice<String>(value: 'da', title: 'Danish'),
    S2Choice<String>(value: 'nl', title: 'Dutch'),
    S2Choice<String>(value: 'en', title: 'English'),
    S2Choice<String>(value: 'eo', title: 'Esperanto'),
    S2Choice<String>(value: 'et', title: 'Estonian'),
    S2Choice<String>(value: 'fi', title: 'Finnish'),
    S2Choice<String>(value: 'fr', title: 'French'),
    S2Choice<String>(value: 'fy', title: 'Frisian'),
    S2Choice<String>(value: 'gl', title: 'Galician'),
    S2Choice<String>(value: 'ka', title: 'Georgian'),
    S2Choice<String>(value: 'de', title: 'German'),
    S2Choice<String>(value: 'el', title: 'Greek'),
    S2Choice<String>(value: 'gu', title: 'Gujarati'),
    S2Choice<String>(value: 'ht', title: 'Haitian Creole'),
    S2Choice<String>(value: 'ha', title: 'Hausa'),
    S2Choice<String>(value: 'haw', title: 'Hawaiian'),
    S2Choice<String>(value: 'he', title: 'Hebrew'),
    S2Choice<String>(value: 'hi', title: 'Hindi'),
    S2Choice<String>(value: 'hmn', title: 'Hmong'),
    S2Choice<String>(value: 'hu', title: 'Hungarian'),
    S2Choice<String>(value: 'is', title: 'Icelandic'),
    S2Choice<String>(value: 'ig', title: 'Igbo'),
    S2Choice<String>(value: 'id', title: 'Indonesian'),
    S2Choice<String>(value: 'ga', title: 'Irish'),
    S2Choice<String>(value: 'it', title: 'Italian'),
    S2Choice<String>(value: 'ja', title: 'Japanese'),
    S2Choice<String>(value: 'jv', title: 'Javanese'),
    S2Choice<String>(value: 'kn', title: 'Kannada'),
    S2Choice<String>(value: 'kk', title: 'Kazakh'),
    S2Choice<String>(value: 'km', title: 'Khmer'),
    S2Choice<String>(value: 'rw', title: 'Kinyarwanda'),
    S2Choice<String>(value: 'ko', title: 'Korean'),
    S2Choice<String>(value: 'ku', title: 'Kurdish'),
    S2Choice<String>(value: 'ky', title: 'Kyrgyz'),
    S2Choice<String>(value: 'lo', title: 'Lao'),
    S2Choice<String>(value: 'la', title: 'Latin'),
    S2Choice<String>(value: 'lv', title: 'Latvian'),
    S2Choice<String>(value: 'lt', title: 'Lithuanian'),
    S2Choice<String>(value: 'lb', title: 'Luxembourgish'),
    S2Choice<String>(value: 'mk', title: 'Macedonian'),
    S2Choice<String>(value: 'mg', title: 'Malagasy'),
    S2Choice<String>(value: 'ms', title: 'Malay'),
    S2Choice<String>(value: 'ml', title: 'Malayalam'),
    S2Choice<String>(value: 'mt', title: 'Maltese'),
    S2Choice<String>(value: 'mi', title: 'Maori'),
    S2Choice<String>(value: 'mr', title: 'Marathi'),
    S2Choice<String>(value: 'mn', title: 'Mongolian'),
    S2Choice<String>(value: 'my', title: 'Myanmar (Burmese)'),
    S2Choice<String>(value: 'ne', title: 'Nepali'),
    S2Choice<String>(value: 'no', title: 'Norwegian'),
    S2Choice<String>(value: 'ny', title: 'Nyanja (Chichewa)'),
    S2Choice<String>(value: 'or', title: 'Odia (Oriya)'),
    S2Choice<String>(value: 'ps', title: 'Pashto'),
    S2Choice<String>(value: 'fa', title: 'Persian'),
    S2Choice<String>(value: 'pl', title: 'Polish'),
    S2Choice<String>(value: 'pt', title: 'Portuguese (Portugal, Brazil)'),
    S2Choice<String>(value: 'pa', title: 'Punjabi'),
    S2Choice<String>(value: 'ro', title: 'Romanian'),
    S2Choice<String>(value: 'ru', title: 'Russian'),
    S2Choice<String>(value: 'sm', title: 'Samoan'),
    S2Choice<String>(value: 'gd', title: 'Scots Gaelic'),
    S2Choice<String>(value: 'sr', title: 'Serbian'),
    S2Choice<String>(value: 'st', title: 'Sesotho'),
    S2Choice<String>(value: 'sn', title: 'Shona'),
    S2Choice<String>(value: 'sd', title: 'Sindhi'),
    S2Choice<String>(value: 'si', title: 'Sinhala (Sinhalese)'),
    S2Choice<String>(value: 'sk', title: 'Slovak'),
    S2Choice<String>(value: 'sl', title: 'Slovenian'),
    S2Choice<String>(value: 'so', title: 'Somali'),
    S2Choice<String>(value: 'es', title: 'Spanish'),
    S2Choice<String>(value: 'su', title: 'Sundanese'),
    S2Choice<String>(value: 'sw', title: 'Swahili'),
    S2Choice<String>(value: 'sv', title: 'Swedish'),
    S2Choice<String>(value: 'tl', title: 'Tagalog (Filipino)'),
    S2Choice<String>(value: 'tg', title: 'Tajik'),
    S2Choice<String>(value: 'ta', title: 'Tamil'),
    S2Choice<String>(value: 'tt', title: 'Tatar'),
    S2Choice<String>(value: 'te', title: 'Telugu'),
    S2Choice<String>(value: 'th', title: 'Thai'),
    S2Choice<String>(value: 'tr', title: 'Turkish'),
    S2Choice<String>(value: 'tk', title: 'Turkmen'),
    S2Choice<String>(value: 'uk', title: 'Ukrainian'),
    S2Choice<String>(value: 'ur', title: 'Urdu'),
    S2Choice<String>(value: 'ug', title: 'Uyghur'),
    S2Choice<String>(value: 'uz', title: 'Uzbek'),
    S2Choice<String>(value: 'vi', title: 'Vietnamese'),
    S2Choice<String>(value: 'cy', title: 'Welsh'),
    S2Choice<String>(value: 'xh', title: 'Xhosa'),
    S2Choice<String>(value: 'yi', title: 'Yiddish'),
    S2Choice<String>(value: 'yo', title: 'Yoruba'),
    S2Choice<String>(value: 'zu', title: 'Zulu'),
  ];

  List<S2Choice<String>> levels = [
    S2Choice<String>(value: '1', title: 'Beginner'),
    S2Choice<String>(value: '2', title: 'Elementary'),
    S2Choice<String>(value: '3', title: 'Intermediate'),
    S2Choice<String>(value: '4', title: 'Advanced'),
    S2Choice<String>(value: '5', title: 'Proficient'),
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
                          languages: languages,
                          targetLanguage: targetLanguage,
                          level: level,
                          levels: levels,
                          next: next,
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

class SignupStep2 extends StatefulWidget {
  SignupStep2({
    Key key,
    @required Size size,
    @required this.nativeLanguage,
    @required this.languages,
    @required this.targetLanguage,
    @required this.level,
    @required this.levels,
    @required this.next,
  })  : _size = size,
        super(key: key);

  final Size _size;
  String nativeLanguage;
  final List<S2Choice<String>> languages;
  String targetLanguage;
  String level;
  final List<S2Choice<String>> levels;
  Function next;

  @override
  _SignupStep2State createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                          title: 'Native Language',
                          placeholder: 'selecet',
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
                          choiceStyle: S2ChoiceStyle(
                            activeColor: Theme.of(context).accentColor,
                            color: Colors.grey,
                            titleStyle: TextStyle(color: Colors.white),
                          ),
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
                          // modalConfig: S2ModalConfig(
                          //   filterAuto: true,
                          //   useConfirm: true,
                          //   confirmColor: Colors.green,
                          // ),
                          // modalConfirm: true,
                          // modalValidation: (value) {
                          //   if (value == '') {
                          //     return 'please select a language';
                          //   }
                          //   return null;
                          // },
                          value: widget.nativeLanguage,
                          choiceItems: widget.languages,
                          onChange: (state) => setState(
                              () => widget.nativeLanguage = state.value)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                //select Native language
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target'),
                      SmartSelect<String>.single(
                        title: 'Language',
                        placeholder: 'selecet',
                        tileBuilder: (context, state) {
                          return S2Tile.fromState(
                            state,
                            title: Text('Language',
                                style: TextStyle(color: Colors.white)),
                          );
                        },
                        modalFilterHint: 'search languages',
                        choiceHeaderStyle: S2ChoiceHeaderStyle(
                            textStyle: TextStyle(color: Colors.white)),
                        choiceStyle: S2ChoiceStyle(
                          activeColor: Theme.of(context).accentColor,
                          color: Colors.grey,
                          titleStyle: TextStyle(color: Colors.white),
                        ),
                        modalHeaderStyle: S2ModalHeaderStyle(
                          actionsIconTheme: IconThemeData(color: Colors.white),
                          iconTheme: IconThemeData(color: Colors.white),
                          textStyle: TextStyle(color: Colors.white),
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                        ),
                        modalStyle: S2ModalStyle(
                            backgroundColor: Theme.of(context).cardColor),
                        modalFilter: true,
                        // modalConfig: S2ModalConfig(
                        //   filterAuto: true,
                        //   useConfirm: true,
                        //   confirmColor: Colors.green,
                        // ),
                        // modalConfirm: true,
                        // modalValidation: (value) {
                        //   if (value == '') {
                        //     return 'please select a language';
                        //   }
                        //   return null;
                        // },
                        value: widget.targetLanguage,
                        choiceItems: widget.languages,
                        onChange: (state) {
                          setState(() {
                            widget.targetLanguage = state.value;
                          });
                        },
                      ),
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
                                style: TextStyle(color: Colors.white)),
                          );
                        },
                        placeholder: 'selecet',
                        choiceHeaderStyle: S2ChoiceHeaderStyle(
                            textStyle: TextStyle(color: Colors.white)),
                        choiceStyle: S2ChoiceStyle(
                          activeColor: Theme.of(context).accentColor,
                          color: Colors.grey,
                          titleStyle: TextStyle(color: Colors.white),
                        ),
                        modalHeaderStyle: S2ModalHeaderStyle(
                          actionsIconTheme: IconThemeData(color: Colors.white),
                          iconTheme: IconThemeData(color: Colors.white),
                          textStyle: TextStyle(color: Colors.white),
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                        ),
                        modalStyle: S2ModalStyle(
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        // modalConfig: S2ModalConfig(
                        //   useConfirm: true,
                        //   confirmColor: Colors.green,
                        // ),
                        // modalConfirm: true,
                        // modalValidation: (value) {
                        //   if (value == '') {
                        //     return 'please select a level';
                        //   }
                        //   return null;
                        // },
                        value: widget.level,
                        choiceItems: widget.levels,
                        onChange: (state) =>
                            setState(() => widget.level = state.value),
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
                        if (widget.nativeLanguage == '' ||
                            widget.targetLanguage == '' ||
                            widget.level == '') {
                          // error = 'please fill all fields';
                          SnackBar registrationBar = SnackBar(
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
                          widget.next();
                        }
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
