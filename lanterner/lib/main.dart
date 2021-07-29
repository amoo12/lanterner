import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/routes/routes.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// prevents screen rotation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // initialize firebase
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

Map<int, Color> color = {
  50: Color.fromRGBO(27, 30, 40, .1),
  100: Color.fromRGBO(27, 30, 40, .2),
  200: Color.fromRGBO(27, 30, 40, .3),
  300: Color.fromRGBO(27, 30, 40, .4),
  400: Color.fromRGBO(27, 30, 40, .5),
  500: Color.fromRGBO(27, 30, 40, .6),
  600: Color.fromRGBO(27, 30, 40, .7),
  700: Color.fromRGBO(27, 30, 40, .8),
  800: Color.fromRGBO(27, 30, 40, .9),
  900: Color.fromRGBO(27, 30, 40, 1),
};
Map<int, Color> color2 = {
  50: Color.fromRGBO(44, 193, 215, .1),
  100: Color.fromRGBO(44, 193, 215, .2),
  200: Color.fromRGBO(44, 193, 215, .3),
  300: Color.fromRGBO(44, 193, 215, .4),
  400: Color.fromRGBO(44, 193, 215, .5),
  500: Color.fromRGBO(44, 193, 215, .6),
  600: Color.fromRGBO(44, 193, 215, .7),
  700: Color.fromRGBO(44, 193, 215, .8),
  800: Color.fromRGBO(44, 193, 215, .9),
  900: Color.fromRGBO(44, 193, 215, 1),
};
Map<int, Color> color3 = {
  50: Color.fromRGBO(52, 58, 80, .1),
  100: Color.fromRGBO(52, 58, 80, .2),
  200: Color.fromRGBO(52, 58, 80, .3),
  300: Color.fromRGBO(52, 58, 80, .4),
  400: Color.fromRGBO(52, 58, 80, .5),
  500: Color.fromRGBO(52, 58, 80, .6),
  600: Color.fromRGBO(52, 58, 80, .7),
  700: Color.fromRGBO(52, 58, 80, .8),
  800: Color.fromRGBO(52, 58, 80, .9),
  900: Color.fromRGBO(52, 58, 80, 1),
};

Map<int, Color> color4 = {
  50: Color.fromRGBO(68, 74, 102, .1),
  100: Color.fromRGBO(68, 74, 102, .2),
  200: Color.fromRGBO(68, 74, 102, .3),
  300: Color.fromRGBO(68, 74, 102, .4),
  400: Color.fromRGBO(68, 74, 102, .5),
  500: Color.fromRGBO(68, 74, 102, .6),
  600: Color.fromRGBO(68, 74, 102, .7),
  700: Color.fromRGBO(68, 74, 102, .8),
  800: Color.fromRGBO(68, 74, 102, .9),
  900: Color.fromRGBO(68, 74, 102, 1),
};

// TODO: update the colors simply like this in a separate file
// class AppColors {
//   static const primaryColor = Color(0xff323F6C);
//   static const primaryColorLight = Color(0xfffa897b);
//   static const accentColor = Color(0xff1aa687);
//   static const accentColorLight = Color(0xffd9ecf2);
//   static const cardColor = Color(0xff445694);
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lanterner',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF353A50, color),
        accentColor: MaterialColor(0xFF2CC1D7, color2),
        scaffoldBackgroundColor: MaterialColor(0xFF1B1E28, color3),
        cardColor: MaterialColor(0xFF444A66, color4),
        dialogBackgroundColor: MaterialColor(0xFF444A66, color4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'OpenSans-Regular',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.red,
          selectionColor: MaterialColor(0xFF2CC1D7, color2).shade300,
          selectionHandleColor: MaterialColor(0xFF2CC1D7, color2),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 72.0,
          ),
          headline2: TextStyle(fontSize: 25.0, color: Colors.white),
          bodyText2: TextStyle(color: Colors.grey, fontSize: 16),
          headline4: TextStyle(color: Colors.red, fontSize: 16),
          // text for main button
          button: TextStyle(color: Colors.white, fontSize: 18),
          // text for secondary button
          //text with the accent color for links
        ),
      ),
      home: Wrapper(),
      // this is coming from the routes page
      routes: routes,
    );
  }
}
