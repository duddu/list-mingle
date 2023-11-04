import 'package:list_mingle/providers/view_lists.dart';
import 'package:riverpod/riverpod.dart';

final viewActiveListProvider =
    AutoDisposeFutureProvider<ViewListModel>((ref) async {
  final viewLists = await ref.watch(viewListsProvider.future);
  return viewLists.singleWhere((list) => list.active);
});
