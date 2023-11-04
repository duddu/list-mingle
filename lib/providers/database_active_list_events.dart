// import 'package:firebase_database/firebase_database.dart';
// import 'package:list_mingle/providers/database_lists_references.dart';
// import 'package:list_mingle/providers/view_active_list.dart';
// import 'package:list_mingle/providers/view_lists.dart';
// import 'package:riverpod/riverpod.dart';

// final databaseActiveListValueEventProvider =
//     AutoDisposeStreamProvider<DatabaseEvent>((ref) async* {
//   final ViewListModel viewActiveList =
//       await ref.watch(viewActiveListProvider.future);
//   final List<DatabaseReference> listsRefs =
//       await ref.read(databaseListsReferencesProvider.future);
//   final DatabaseReference activeListRef =
//       listsRefs.singleWhere((listRef) => listRef.key == viewActiveList.id);
//   yield* activeListRef.onValue.asBroadcastStream();
// });
