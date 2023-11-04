import 'package:list_mingle/providers/view_lists.dart';
import 'package:riverpod/riverpod.dart';

final viewActiveListProvider =
    AutoDisposeFutureProvider<ViewListModel>((ref) async {
  final viewLists = ref.watch(viewListsProvider);
  return viewLists.value!.singleWhere((list) => list.active);
});
