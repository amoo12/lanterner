import 'package:flutter/material.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:lanterner/widgets/progressIndicator.dart';

class MyPosts extends StatelessWidget {
  final User user;
  MyPosts({Key key, this.user}) : super(key: key);
  final DatabaseService db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.name}'s posts"),
      ),
      body: FutureBuilder(
          future: db.getUserPosts(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Post> posts = [];
              posts = snapshot.data;
              if (posts.length > 0) {
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index]);
                  },
                );
              } else {
                return Container(
                    child: Center(
                  child: Text('No posts uploaded yet'),
                ));
              }
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("ERROR: Someting went wrong");
            } else {
              return circleIndicator(context);
            }
          }),
    );
  }
}
