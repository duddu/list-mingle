import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:list_mingle/providers/database_lists_references.dart';
import 'package:list_mingle/providers/shared_preferences_lists.dart';
import 'package:list_mingle/providers/shared_preferences_user.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class ViewListModel extends DatabaseListModel {
  const ViewListModel(
      {required this.id,
      required this.active,
      required super.name,
      required super.author,
      required super.timestamp});

  final String id;
  final bool active;

  factory ViewListModel.fromDatabaseListSnapshot(
      DataSnapshot snapshot, bool isActive) {
    try {
      final String id = snapshot.key!;
      final DatabaseListData value = snapshot.value! as DatabaseListData;
      return ViewListModel(
          id: id,
          active: isActive,
          name: value['name'] as String,
          author: value['author'] as String,
          timestamp: value['timestamp'] as int);
    } catch (e) {
      throw FormatException(
          e.toString(), '${snapshot.key}=${snapshot.value.toString()}');
    }
  }
}

class ViewListsNotifier extends AutoDisposeAsyncNotifier<List<ViewListModel>> {
  DatabaseListsReferencesNotifier get _listsRefsNotifier =>
      ref.read(databaseListsReferencesProvider.notifier);

  Future<void> insert(String name) async {
    state = const AsyncValue.loading();
    final DatabaseReference newListRef = _listsRefsNotifier.getNewListRef();
    final SharedPreferencesUser? user =
        await ref.read(sharedPreferencesUserProvider.future);
    final ViewListModel newLocalList = ViewListModel(
        id: newListRef.key!,
        active: true,
        name: name,
        author: user?.name ?? 'Unknown',
        timestamp: DateTime.now().microsecondsSinceEpoch);
    return _listsRefsNotifier.addList(
        newListRef, newLocalList.toDatabaseListData());
  }

  Future<void> edit(String listId, String editedName) async {
    if (editedName.isNotEmpty) {
      state.whenData((lists) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final ViewListModel editingList =
              lists.singleWhere((list) => list.id == listId);
          final ViewListModel editedLocalList = ViewListModel(
              id: listId,
              active: editingList.active,
              name: editedName,
              author: editingList.author,
              timestamp: DateTime.now().microsecondsSinceEpoch);
          _listsRefsNotifier.editList(
              listId, editedLocalList.toDatabaseListData());
          return lists
              .map((list) => list.id == listId ? editedLocalList : list)
              .toList();
        });
      });
    }
  }

  Future<void> setActive(String activeListId) async {
    state.whenData((lists) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final sharedPreferencesListsNotifier =
            ref.read(sharedPreferencesListsProvider.notifier);
        await sharedPreferencesListsNotifier.setActive(activeListId);
        return lists
            .map((list) => ViewListModel(
                id: list.id,
                active: list.id == activeListId,
                name: list.name,
                author: list.author,
                timestamp: DateTime.now().microsecondsSinceEpoch))
            .toList();
      });
    });
  }

  Future<void> remove(String listKey) async {
    state = const AsyncValue.loading();
    return _listsRefsNotifier.removeList(listKey);
  }

  // void _onActiveListValueCallback(_, AsyncValue<DatabaseEvent> event) {
  //   if (event.value == null) {
  //     return;
  //   }
  //   state.whenData((lists) async {
  //     final changedList =
  //         ViewListModel.fromDatabaseListSnapshot(event.value!.snapshot, true);
  //     if (changedList.timestamp ==
  //         lists.singleWhere((list) => list.id == changedList.id).timestamp) {
  //       return;
  //     }
  //     state = AsyncValue.data(lists
  //         .map((list) => list.id != changedList.id ? list : changedList)
  //         .toList());
  //   });
  // }

  @override
  Future<List<ViewListModel>> build() async {
    await ref.watch(databaseListsReferencesProvider.future);
    final listsSnapshots = await _listsRefsNotifier.getListsSnapshotsOnce();
    if (listsSnapshots.isEmpty) {
      return [];
    }
    // ref.listen<AsyncValue<DatabaseEvent>>(
    //     databaseActiveListValueEventProvider, _onActiveListValueCallback);
    String? activeListId =
        (await ref.read(sharedPreferencesListsProvider.future)).activeList;
    return listsSnapshots.map((snapshot) {
      final bool isActive = snapshot.key == activeListId;
      return ViewListModel.fromDatabaseListSnapshot(snapshot, isActive);
    }).toList();
  }
}

final viewListsProvider =
    AutoDisposeAsyncNotifierProvider<ViewListsNotifier, List<ViewListModel>>(
        ViewListsNotifier.new);
