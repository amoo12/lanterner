import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/activity.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/pages/comments.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:logger/logger.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:intl/intl.dart';

Logger logger = Logger();

class ActivityList extends StatefulWidget {
  const ActivityList({Key key, this.menuScreenContext}) : super(key: key);
  final menuScreenContext;
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  Future<List<Activity>> activityFuture;
  DatabaseService db = DatabaseService();
  String currentUserId;

  fetchActivities() {
    activityFuture = db.getUserActivity(currentUserId);
  }

  @override
  void initState() {
    super.initState();
    currentUserId = context.read(authStateProvider).data.value.uid;
    fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    // final _authState = watch(authStateProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Activity'),
      ),
      body: FutureBuilder<List<Activity>>(
        future: db.getUserActivity(currentUserId),
        builder: (context, snapshot) {
          // logger.d(snapshot.data.length.toString());
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Activity> activities = snapshot.data;

              return ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        tileColor: Theme.of(context).cardColor,
                        leading: ProfileImage(
                          size: 20,
                          context: context,
                          currentUserId: currentUserId,
                          ownerId: activities[index].user.uid,
                          photoUrl: activities[index].user.photoUrl,
                        ),
                        title: Text(
                          activities[index].user.name,
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                        subtitle: Text(
                          activities[index].type == 'like'
                              ? 'liked your post'
                              : activities[index].type == 'comment'
                                  ? 'commented on your post'
                                  : '',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        trailing: Text(
                          '${getChatTime(activities[index].timestamp)}',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () async {
                          customProgressIdicator(context);
                          Post post =
                              await db.getPost(activities[index].postId);
                          pushNewScreenWithRouteSettings(
                            context,
                            settings:
                                RouteSettings(name: '/comments_from_activity'),
                            screen: Comments(
                              herotag: '',
                              post: post,
                            ),
                            pageTransitionAnimation:
                                PageTransitionAnimation.fade,
                            withNavBar: false,
                          );
                        },
                      ),
                      activities.length == index + 1
                          ? SizedBox()
                          : Divider(
                              height: 0,
                              indent: 70,
                              color: Colors.grey,
                              thickness: 0.2,
                            ),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              logger.d(snapshot.error.toString());
            }
            return Container(
              child: Center(child: Text('BS')),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return circleIndicator(context);
          } else {
            return circleIndicator(context);
          }
        },
      ),
    );
  }

  String getChatTime(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    String msg = '';
    var dt = DateTime.parse(date).toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    if (dur.inDays > 0) {
      msg = '${dur.inDays} d';
      return dur.inDays == 1 ? '1d' : DateFormat("dd MMM hh:mm").format(dt);
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours} h';
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes} m';
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds} s';
    } else {
      msg = 'now';
    }
    return msg;
  }
}
