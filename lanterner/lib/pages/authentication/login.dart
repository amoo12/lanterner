import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lanterner/widgets/buttons.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/customToast.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'dart:math' as math;
// import '../models/user.dart';
import '../../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String email;
  String password;
  String error;

  FToast fToast;

  _submit(AuthenticationService _auth) async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final toastMessage = await _auth.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      showToast(fToast, toastMessage);
    }
  }

  _goToSignup() {
    Navigator.pushNamed(context, '/signup');
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

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      // listen to the AuthenticationService class
      final _auth = watch(authServicesProvider);

      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).copyWith().size.height,
                  width: MediaQuery.of(context).copyWith().size.width,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/wishes.svg',
                        height: MediaQuery.of(context).size.width / 2.5,
                      ),
                      Text(
                        'Lanterner',
                        style: TextStyle(
                            fontFamily: 'FORTE',
                            fontSize: 35,
                            color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Login',
                        style: TextStyle(
                            fontFamily: 'OpenSans-Regular',
                            fontSize: 25,
                            color: Colors.white),
                      ),
                      Form(
                        key: _formKey,
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextFormFieldWidget(
                              lableText: 'Email',
                              onSaved: onSavedEmail,
                              validatorMessage: 'Enter an email',
                              controller: emailController,
                              scrollPadding: 200,
                            ),
                            TextFormFieldWidget(
                              lableText: 'Password',
                              onSaved: onSavedPassword,
                              validatorMessage: 'Enter a password',
                              controller: passwordController,
                              obscureText: true,
                              scrollPadding: 140,
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),

                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final toastMessage = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ResetPassword()));

                                    if (toastMessage != null) {
                                      showToast(fToast, toastMessage, 5);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(50, 30),
                                      alignment: Alignment.centerLeft),
                                  child: Text.rich(TextSpan(
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                      text: 'Forgot Password? ',
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: 'Reset',
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ])),
                                ),
                              ],
                            ),
                            if (error != null)
                              Text(
                                error,
                                style: TextStyle(
                                    color: Colors.red[300], fontSize: 14.0),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ButtonWidget(
                                  context: context,
                                  text: 'Login',
                                  onPressed: () {
                                    _submit(_auth);
                                  }),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: ButtonWidget(
                                  buttonType: 2,
                                  context: context,
                                  text: 'Create an Account',
                                  onPressed: _goToSignup),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (FocusScope.of(context).hasFocus)
                              SizedBox(
                                height: 20,
                              ),
                            // RichText(
                            //   text: TextSpan(
                            //       style: Theme.of(context).textTheme.bodyText2,
                            //       children: [
                            //         TextSpan(
                            //           text: "Don't have an account? ",
                            //         ),
                            //         TextSpan(
                            //             style: Theme.of(context)
                            //                 .textTheme
                            //                 .bodyText2
                            //                 .copyWith(
                            //                     color:
                            //                         Theme.of(context).accentColor),
                            //             text: 'Register',
                            //             recognizer: TapGestureRecognizer()
                            //               ..onTap = () {
                            //                 // Navigator.pushNamed(context, 'Signup');
                            //               }),
                            //       ]),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      );
    });
  }
}

class ResetPassword extends StatefulWidget {
  ResetPassword({Key key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController;
  String email;
  String error;
  AuthenticationService _auth;
  onSavedEmail(String value) {
    if (!EmailValidator.validate(value)) {
      error = "enter a valid email";
      setState(() {});
    } else {
      setState(() {
        email = value;
        error = null;
      });
    }
  }

  _submit() async {
    final form = _formKey.currentState;

    // onSavedEmail(emailController.text.trim());
    // if (error != null) {
    if (form.validate()) {
      form.save();
      _auth.resetPassword(email);
    }
    // }
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    _auth = context.read(authServicesProvider);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        error = null;
        return true;
      },
      child: Scaffold(
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
                error = null;
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Reset password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your registered email',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: TextFormFieldWidget(
                    lableText: 'Email',
                    onSaved: onSavedEmail,
                    validatorMessage: 'Enter an email',
                    controller: emailController,
                    autofocus: true,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (error != null)
                  Text(
                    error,
                    style: TextStyle(color: Colors.red[300], fontSize: 14.0),
                  ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                      context: context,
                      text: 'Send Reset Email',
                      onPressed: () async {
                        if (!EmailValidator.validate(
                            emailController.text.trim())) {
                          setState(() {
                            error = "enter a valid email";
                          });
                        } else {
                          await _submit();
                          error = 'An email has been sent to ' +
                              emailController.text.trim();
                          Navigator.pop(context, error);
                        }
                      }),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
