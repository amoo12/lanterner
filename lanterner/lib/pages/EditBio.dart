import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/services/databaseService.dart';

class EditBio extends StatefulWidget {
  final String uid;
  final String bio;
  EditBio({Key key, this.uid, this.bio}) : super(key: key);

  @override
  _EditBioState createState() => _EditBioState();
}

class _EditBioState extends State<EditBio> {
  String text = '';

  TextEditingController bioController;
  DatabaseService db;
  @override
  void initState() {
    bioController = TextEditingController();
    bioController.text = widget.bio == null ? '' : widget.bio;
    db = DatabaseService();
    super.initState();
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Edit bio'),
        actions: [
          TextButton(
              onPressed: bioController.text.trim().isNotEmpty
                  ? () async {
                      await db.updateBio(widget.uid, bioController.text.trim());
                      Navigator.pop(context, bioController.text.trim());
                    }
                  : null,
              child: Text(
                'Save',
                style: TextStyle(
                    color: bioController.text.trim().isNotEmpty
                        ? Colors.white
                        : Colors.grey[600]),
              ))
        ],
      ),
      body: SafeArea(
          child: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
                    controller: bioController,
                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
