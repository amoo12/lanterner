import 'package:flutter/material.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/progressIndicator.dart';

class FollowersList extends StatelessWidget {
  final String currentUserId;
  bool followingPage;
  FollowersList({Key key, this.currentUserId}) : super(key: key);

  final DatabaseService db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(ModalRoute.of(context).settings.name == '/followers'
              ? 'Followers'
              : 'Following'),
        ),
        body: FutureBuilder(
            future: ModalRoute.of(context).settings.name == '/followers'
                ? db.getFollowers(currentUserId)
                : db.getFollowing(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<User> users = snapshot.data;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: buildCircleAvatar(
                        context: context,
                        ownerId: users[index].uid,
                        currentUserId: currentUserId,
                        photoUrl: users[index].photoUrl,
                        size: 22,
                      ),
                      title: Text(
                        '${users[index].name}',
                        style: TextStyle(color: Colors.white),
                      ),
                      // trailing: Text('button'),
                    );
                  },
                );
              } else {
                return circleIndicator(context);
              }
            }));
  }
}

// class Users {
//   final String name;
//   final String avatar;
//   Users({this.name, this.avatar});
// }

// class FilterPage extends StatelessWidget {
//   FilterPage({Key key}) : super(key: key);
//   List<Users> userList = [
//     Users(name: "Jon", avatar: ""),
//     Users(name: "Ethel ", avatar: ""),
//     Users(name: "Elyse ", avatar: ""),
//     Users(name: "Nail  ", avatar: ""),
//     Users(name: "Valarie ", avatar: ""),
//     Users(name: "Lindsey ", avatar: ""),
//     Users(name: "Emelyan ", avatar: ""),
//     Users(name: "Carolina ", avatar: ""),
//     Users(name: "Catherine ", avatar: ""),
//     Users(name: "Stepanida  ", avatar: ""),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Filter List Widget Example "),
//       ),
//       body: SafeArea(
//         child: FilterListWidget<Users>(
//           hideSelectedTextCount: true,
//           listData: userList,
//           hideHeaderText: true,
//           // onApplyButtonClick: (list) {
//           //   if (list != null) {
//           //     print("Selected items count: ${list.length}");
//           //   }
//           // },
//           choiceChipLabel: (item) {
//             /// Used to print text on chip
//             return item.name;
//           },
//           // label: (item) {
//           /// Used to print text on chip
//           // return item.name;
//           // },
//           validateSelectedItem: (list, val) {
//             ///  identify if item is selected or not
//             return list.contains(val);
//           },
//           onItemSearch: (list, text) {
//             /// When text change in search text field then return list containing that text value
//             ///
//             ///Check if list has value which matchs to text
//             if (list.any((element) =>
//                 element.name.toLowerCase().contains(text.toLowerCase()))) {
//               /// return list which contains matches
//               return list
//                   .where((element) =>
//                       element.name.toLowerCase().contains(text.toLowerCase()))
//                   .toList();
//             } else {
//               return [];
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
