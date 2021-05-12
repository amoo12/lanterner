import 'package:flutter/material.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'dart:math' as math;

class NewPost extends StatefulWidget {
  NewPost({Key key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('New post'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.send,
            ),
          )
        ],
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
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              // height: 200,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    // height: 200,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TextFormFieldWidget(
                      bottomBorder: false,
                      hintText: 'Say something',
                      expands: true,
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[900],
                      blurRadius: 0.5,
                      spreadRadius: 0.5,
                    ),
                  ]),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo_outlined),
                        color: Colors.grey[400],
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.mic),
                        color: Colors.grey[400],
                        onPressed: () {},
                      )
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
