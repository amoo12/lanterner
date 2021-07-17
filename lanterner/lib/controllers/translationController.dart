import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class TranslationController {
  final translator = GoogleTranslator();
  Translation translation;
  final DatabaseService db = DatabaseService();
  TranslationController();

  Future<Translation> translate(
      {String textTotrasnlate, String uid, Message message}) async {
    final prefs = await SharedPreferences.getInstance();
    String translateTo;

    String alternativeTranslation;

    // fetch the user's target translation language
    if (prefs.containsKey('preferred_translation_language') &&
        prefs.containsKey('targetlanguage')) {
      translateTo = prefs.getString('preferred_translation_language');
      alternativeTranslation = prefs.getString('targetlanguage');
    } else {
      // final DatabaseService db = DatabaseService();
      // final uid = context.read(authStateProvider).data.value.uid;
      final User user = await db.getUser(uid);
      prefs.setString(
          'preferred_translation_language', user.nativeLanguage.code);
      prefs.setString('targetlanguage', user.targetLanguage.code);
      translateTo = user.nativeLanguage.code;
      alternativeTranslation = user.targetLanguage.code;
    }

    // auto detect the source language and translates to target language
    translation = await translator.translate(textTotrasnlate, to: translateTo);

    // if the text is the same as the prefered transaltion language then translate to the user's target language
    if (translation.sourceLanguage.code == translateTo) {
      translation = await translator.translate(textTotrasnlate,
          to: alternativeTranslation);
    }

    if (message != null) {
      message.translation = translation.text;
      db.saveMessageTranslation(message);
      // prefs.setString(storeId, translation.text);
    }

    return translation;
  }
}
