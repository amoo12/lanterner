import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  ChatsList({Key key}) : super(key: key);

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  List<int> _items = [];

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('chats'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            AnimatedList(
              key: listKey,
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) {
                return slideIt(context, index, animation); // Refer step 3
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: Row(
                    children: [
                      ElevatedButton(
                        child: Text('add'),
                        onPressed: () {
                          listKey.currentState.insertItem(0,
                              duration: const Duration(milliseconds: 400));
                          _items = []
                            ..add(counter++)
                            ..addAll(_items);
                        },
                      ),
                      ElevatedButton(
                        child: Text('remove'),
                        onPressed: () {
                          listKey.currentState.removeItem(0,
                              (_, animation) => slideIt(context, 0, animation),
                              duration: const Duration(milliseconds: 400));
                        },
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  Widget slideIt(BuildContext context, int index, animation) {
    int item = _items[index];
    TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset(0, 0),
        ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutBack,
            reverseCurve: Curves.easeInOut)),
        child: Container(
          child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            title: Text('name', style: TextStyle(color: Colors.white)),
            subtitle:
                Text('last message', style: TextStyle(color: Colors.grey)),
            trailing: Text('date'),
          ),
        ));
  }
}
