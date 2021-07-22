import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../models/user.dart';
import '../services/databaseService.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  GlobalKey _scaffold = GlobalKey();
  Future<QuerySnapshot> searchResultsFuture;
  DatabaseService db = DatabaseService();

  String uid;
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
    });
    uid = context.read(authStateProvider).data.value.uid;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String searchText;
  handleSearch(String searchText) {
    setState(() {
      this.searchText = searchText;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      this.searchText = '';
    });
  }

  AppBar buildSerachField() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user',
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(width: 0, color: Theme.of(context).primaryColor)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(width: 3, color: Theme.of(context).primaryColor),
              gapPadding: 0),
          fillColor: Theme.of(context).backgroundColor,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey[600],
            ),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
        onChanged: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientaion = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // SvgPicture.asset(
            //   'assets/images/search.svg',
            //   height: 300.0,
            //   colorBlendMode: BlendMode.softLight,
            // ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                // fontStyle: FontStyle.italic,
                // fontWeight: FontWeight.w600,
                // fontSize: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: db.searchUsers(searchText, uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> searchResults = snapshot.data;

            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return UserResult(searchResults[index], uid);
              },
            );
          } else {
            return circleIndicator(context);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffold,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(1),
        appBar: buildSerachField(),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: searchText == null || searchText == ''
              ? buildNoContent()
              : buildSearchResults(),
        ));
  }
}

class UserResult extends StatelessWidget {
  final User user;
  final String currentUserId;

  UserResult(this.user, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: ListTile(
              onTap: () {
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: '/profile'),
                  screen: Profile(uid: user.uid),
                  pageTransitionAnimation: PageTransitionAnimation.slideUp,
                  withNavBar: false,
                );
              },
              leading: ProfileImage(
                size: 25,
                context: context,
                currentUserId: currentUserId,
                ownerId: user.uid,
                photoUrl: user.photoUrl,
              ),
              // CachedNetworkImageProvider(user.photoUrl),
              title: Text(
                user.name,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.name, style: TextStyle(color: Colors.white)),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
