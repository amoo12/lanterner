import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/comment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final commentProvider =
    StateNotifierProvider.autoDispose<CommentsList, List<Comment>>((ref) {
  return CommentsList([]);
});

class CommentsList extends StateNotifier<List<Comment>> {
  CommentsList([List<Comment> initialComments]) : super(initialComments ?? []);

  void add(Comment comment) {
    state = [...state, comment];
  }

  //TODO: delete comment
  void remove(Comment comment) {
    // state = state.where((element) => element.cid != comment.cid).toList();
    state.remove(comment);
  }
}
