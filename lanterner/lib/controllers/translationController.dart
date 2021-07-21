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
    if (prefs.containsKey('preferred_translation_language' + '#' + uid) &&
        prefs.containsKey('targetlanguage' + '#' + uid)) {
      translateTo =
          prefs.getString('preferred_translation_language' + '#' + uid);

      alternativeTranslation = prefs.getString('targetlanguage' + '#' + uid);
    } else {
      final User user = await db.getUser(uid);
      prefs.setString('preferred_translation_language' + '#' + uid,
          user.nativeLanguage.code);
      prefs.setString('targetlanguage' + '#' + uid, user.targetLanguage.code);
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
    }
    db.incrementTranslations(uid);

    return translation;
  }
}
