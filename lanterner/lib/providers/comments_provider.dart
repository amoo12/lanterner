import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/comment.dart';

// keeps track of newly added comments
final commentProvider =
    StateNotifierProvider.autoDispose<CommentsList, List<Comment>>((ref) {
  return CommentsList([]);
});

class CommentsList extends StateNotifier<List<Comment>> {
  CommentsList([List<Comment> initialComments]) : super(initialComments ?? []);

  void add(Comment comment) {
    // must override the state value to trigger a state change and UI does not rebuild.
    state = [...state, comment];
    // try clearing the list here without overriding state and dont forget to remove the clear line in comments.dart
  }

  void remove(Comment comment) {
//  must override the state variable (state = value) otherwise notifyListners is not called and the widget won't rebuild
    state = state.where((element) => element.cid != comment.cid).toList();
  }
}
