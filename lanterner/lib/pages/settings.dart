import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/languageIndicator.dart';
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
              ListTile(
                onTap: () {},
                leading: Text('Language'),
                title: Center(
                  child: Container(
                    width: 90,
                    // constraints: BoxConstraints(maxWidth: ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        languageIndictor(user.nativeLanguage, Colors.white),
                        Transform.rotate(
                          angle: 180 * math.pi / 180,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.grey,
                            size: 10,
                          ),
                        ),
                        languageIndictor(user.targetLanguage, Colors.white),
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
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            // padding: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                // minimumSize: Size(30, 35),
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
              child: Text('signout'),
            ),
          ),
        ],
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
              builder: (context) => UpdateUserName(
                  uid: widget.user.uid, name: results ?? widget.user.name),
            ));

        setState(() {});
        print(widget.user.name);
      },
      leading: Text('Name'),
      title: Center(
        child: Text(
          results ?? widget.user.name,
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
  final String uid;
  final String name;
  UpdateUserName({Key key, this.name, this.uid}) : super(key: key);
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final DatabaseService db = DatabaseService();
  onSaved() {
    _formKey.currentState.save();
    print(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    controller.text = name;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Name'),
          actions: [
            TextButton(
                onPressed: controller.text.trim().isNotEmpty
                    ? () async {
                        if (controller.text.trim() != name) {
                          customProgressIdicator(context);
                          await db.updateUsername(uid, controller.text.trim());
                          Navigator.pop(context, controller.text.trim());
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
                  child: Text('Press ok to save'))
            ]),
          ),
        ),
      ),
    );
  }
}

class EditNameField extends StatefulWidget {
  EditNameField({Key key}) : super(key: key);

  @override
  _EditNameFieldState createState() => _EditNameFieldState();
}

class _EditNameFieldState extends State<EditNameField> {
  TextEditingController controller;

  String text = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: AutoDirection(
          text: text,
          child: TextFormField(
            cursorColor: Colors.white,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey),
              labelStyle: TextStyle(color: Colors.white),
              focusColor: Colors.white,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            controller: controller,
            onChanged: (value) {
              setState(() {
                text = value;
              });
            },
          ),
        ));
  }
}
