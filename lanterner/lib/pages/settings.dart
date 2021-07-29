import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/languageIndicator.dart';
import 'package:lanterner/widgets/languagesList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../widgets/progressIndicator.dart';

class Settings extends ConsumerWidget {
  final User user;
  const Settings({Key key, this.user}) : super(key: key);

  // DatabaseService db = DatabaseService();
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _auth = watch(authServicesProvider);
    final _authState = watch(authStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              NameListTile(user: user),
              Divider(
                thickness: 0.25,
                // height: 2,
                color: Colors.grey,
              ),
              LanguageListTile(user: user),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 40),
            // padding: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                primary: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () async {
                customProgressIdicator(context);
                await _auth.signout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageListTile extends StatefulWidget {
  const LanguageListTile({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _LanguageListTileState createState() => _LanguageListTileState();
}

class _LanguageListTileState extends State<LanguageListTile> {
  Language newSelectedLangugae;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        newSelectedLangugae = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupStep2(
                user: widget.user,
              ),
            ));
        setState(() {
          widget.user.targetLanguage =
              newSelectedLangugae ?? widget.user.targetLanguage;
        });
      },
      leading: Text('Language'),
      title: Center(
        child: Container(
          width: 90,
          // constraints: BoxConstraints(maxWidth: ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              languageIndictor(widget.user.nativeLanguage, Colors.white),
              Transform.rotate(
                angle: 180 * math.pi / 180,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                  size: 10,
                ),
              ),
              languageIndictor(widget.user.targetLanguage, Colors.white),
            ],
          ),
        ),
      ),
      trailing: Transform.rotate(
        angle: 180 * math.pi / 180,
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

class NameListTile extends StatefulWidget {
  const NameListTile({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _NameListTileState createState() => _NameListTileState();
}

class _NameListTileState extends State<NameListTile> {
  String results;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        results = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateUserName(user: widget.user),
            ));

        setState(() {
          widget.user.name = results ?? widget.user.name;
        });
      },
      leading: Text('Name'),
      title: Center(
        child: Text(
          widget.user.name,
          style: TextStyle(color: Colors.white),
        ),
      ),
      trailing: Transform.rotate(
        angle: 180 * math.pi / 180,
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

class UpdateUserName extends StatelessWidget {
  final User user;
  // final String name;
  UpdateUserName({Key key, this.user}) : super(key: key);
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final DatabaseService db = DatabaseService();
  onSaved() {
    _formKey.currentState.save();
    print(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    controller.text = user.name;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Name'),
          actions: [
            TextButton(
                onPressed: controller.text.trim().isNotEmpty
                    ? () async {
                        if (controller.text.trim() != user.name) {
                          customProgressIdicator(context);
                          user.name = controller.text.trim();
                          await db.updateUsername(user);
                          Navigator.pop(context);
                          Navigator.pop(context, user.name);
                        }
                      }
                    : null,
                child: Text(
                  'Ok',
                  style: TextStyle(
                      color: controller.text.trim().isNotEmpty
                          ? Colors.white
                          : Colors.grey[600]),
                ))
          ],
        ),
        body: Container(
          // width: MediaQuery.of(context).size.width * 0.8,

          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              Form(
                key: _formKey,
                child: TextFormFieldWidget(
                  // lableText: 'Name',
                  onSaved: onSaved,
                  validatorMessage: 'Name must not be empty.',
                  controller: controller,
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Press Ok to save'))
            ]),
          ),
        ),
      ),
    );
  }
}

class SignupStep2 extends StatefulWidget {
  SignupStep2({
    Key key,
    @required this.user,
  }) : super(key: key);

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

  Language selectedtargetLanguage;
  Language translationLanguage;

  GlobalKey<S2SingleState<String>> _targetSelectKey =
      GlobalKey<S2SingleState<String>>();

  DatabaseService db = DatabaseService();
  bool selected = false;
  @override
  void initState() {
    super.initState();
    selectedtargetLanguage = widget.user.targetLanguage;
  }

  @override
  void dispose() {
    super.dispose();
  }

  toggleSelected() {
    selected = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.user.targetLanguage);
        // logger.d(widget.user.targetLanguage.toString());
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            'Languages',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
                onPressed: selected
                    ? () async {
                        if (selectedtargetLanguage != null &&
                            selectedtargetLanguage.level != '') {
                          customProgressIdicator(context);
                          // update in DB
                          await db.updateTargetLanguage(
                              widget.user.uid, selectedtargetLanguage);
                          final prefs = await SharedPreferences.getInstance();
                          // update in local storage
                          await prefs.setString(
                              'targetlanguage' + '#' + widget.user.uid,
                              selectedtargetLanguage.code);
                          Navigator.pop(context);
                          Navigator.pop(context, selectedtargetLanguage);
                        }
                      }
                    : null,
                child: Text(
                  'Ok',
                  style:
                      TextStyle(color: selected ? Colors.white : Colors.grey),
                ))
          ],
        ),
        body: Container(
          // height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            // mainAxisAlignment:,
            children: [
              Container(
                padding: EdgeInsets.only(top: 20),
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    //select Native language
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Native',
                          ),
                          ListTile(
                            leading: Text(
                              'Native',
                              style: TextStyle(color: Colors.white),
                            ),
                            title: Center(
                                child: languageIndictor(
                                    widget.user.nativeLanguage, Colors.white)),
                            trailing: Text(
                              widget.user.nativeLanguage.title,
                              style: TextStyle(color: Colors.white),
                            ),
                          )
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
                            placeholder: selectedtargetLanguage.title,
                            title: 'Language',
                            tileBuilder: (context, state) {
                              return S2Tile.fromState(
                                state,
                                leading: Text('Target',
                                    style: TextStyle(color: Colors.white)),
                                title: Center(
                                    child: selected
                                        ? languageIndictor(
                                            selectedtargetLanguage,
                                            Colors.white)
                                        : languageIndictor(
                                            widget.user.targetLanguage,
                                            Colors.white)),
                                // trailing:
                                //     Text(widget.user.targetLanguage.title)
                              );
                            },
                            modalFilterHint: 'search languages',
                            choiceBuilder: (context, choice, searchText) {
                              return ListTile(
                                leading: Text(
                                  choice.title,
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing:
                                    choice.title == selectedtargetLanguage.title
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                onTap: () async {
                                  targetLanguage = choice.value;
                                  tTitle = choice.title;

                                  selectedtargetLanguage = Language(
                                      code: choice.value,
                                      isNative: false,
                                      level: level,
                                      title: choice.title);
                                  // widget.user.targetLanguage.code = choice.value;
                                  // widget.user.targetLanguage.title = choice.title;
                                  // setState(() async {
                                  if (_targetSelectKey
                                      .currentState.filter.activated)
                                    _targetSelectKey.currentState.filter
                                        .hide(context);

                                  selectedtargetLanguage =
                                      await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LevelList(
                                                selectedtargetLanguage:
                                                    selectedtargetLanguage,
                                                toggleSelected: toggleSelected),
                                          ));

                                  setState(() {});
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
                              setState(() {
                                // selectedtargetLanguage = Language(
                                //     code: targetLanguage,
                                //     isNative: false,
                                //     level: level,
                                //     title: nTitle);
                                // logger.d(selectedtargetLanguage.toString());
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Changing the target language will only affect your future posts. The language on your previouse posts and comments will not change. \nPress Ok to save changes',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelList extends StatelessWidget {
  const LevelList({Key key, this.selectedtargetLanguage, this.toggleSelected})
      : super(key: key);
  final Language selectedtargetLanguage;
  final Function toggleSelected;
  @override
  Widget build(BuildContext context) {
    String lTitle;
    String level;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          title: Text('Level'),
        ),
        body: ListView.builder(
            itemCount: LanguagesList.languageLevels.length,
            itemBuilder: (context, index) => ListTile(
                  leading: Text(
                    LanguagesList.languageLevels[index]['title'],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing:
                      LanguagesList.languageLevels[index]['value'] == lTitle
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                  onTap: () {
                    level = LanguagesList.languageLevels[index]['value'];
                    lTitle = LanguagesList.languageLevels[index]['title'];
                    selectedtargetLanguage.level = level;
                    toggleSelected();
                    Navigator.pop(context, selectedtargetLanguage);
                  },
                )),
      ),
    );
  }
}
