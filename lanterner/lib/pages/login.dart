import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lanterner/widgets/buttons.dart';
import 'package:lanterner/widgets/customTextField.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String email;
  String password;
  String error;

  _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      print('saved');
      form.save();
    }
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
  Widget build(BuildContext context) {
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
                        fontFamily: 'FORTE', fontSize: 35, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 20,
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
                        ),
                        TextFormFieldWidget(
                          lableText: 'Password',
                          onSaved: onSavedPassword,
                          validatorMessage: 'Enter a password',
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 20,
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
                          child: buttonWidget(context, 'Login', _submit),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: [
                                TextSpan(
                                  text: "Don't have an account? ",
                                ),
                                TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                            color:
                                                Theme.of(context).accentColor),
                                    text: 'Register',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigator.pushNamed(context, 'Signup');
                                      }),
                              ]),
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
    );
  }
}
