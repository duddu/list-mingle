import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:list_mingle/providers/database.dart';
import 'package:list_mingle/providers/shared_preferences_lists.dart';
import 'package:riverpod/riverpod.dart';

typedef DatabaseListData = Map<String, dynamic>;

@immutable
class DatabaseListModel {
  const DatabaseListModel(
      {required this.name, required this.author, required this.timestamp});

  final String name;
  final String author;
  final int timestamp;

  DatabaseListData toDatabaseListData() => {
        'name': name,
        'author': author,
        'timestamp': timestamp,
      };
}

class DatabaseListsReferencesNotifier
    extends AutoDisposeAsyncNotifier<List<DatabaseReference>> {
  SharedPreferencesListsNotifier get _sharedPreferencesListsNotifier =>
      ref.read(sharedPreferencesListsProvider.notifier);
  DatabaseReference get _listsRef =>
      ref.read(databaseInstanceProvider).ref('lists');
  DatabaseReference get _tasksRef =>
      ref.read(databaseInstanceProvider).ref('tasks');

  DatabaseReference getNewListRef() => _listsRef.push();

  Future<List<DataSnapshot>> getListsSnapshotsOnce() async {
    final List<DatabaseEvent> events = await Future.wait((state.value ?? [])
        .map((listRef) => listRef.once(DatabaseEventType.value)));
    final List<DataSnapshot> validSnapshots = [];
    final List<DataSnapshot> invalidSnapshots = [];
    for (final event in events) {
      (event.snapshot.exists ? validSnapshots : invalidSnapshots)
          .add(event.snapshot);
    }
    if (invalidSnapshots.isNotEmpty) {
      for (final invalidSnapshot in invalidSnapshots) {
        if (invalidSnapshot.key != null) {
          removeList(invalidSnapshot.key!);
        }
      }
    }
    return validSnapshots;
  }

  Future<void> addList(
      DatabaseReference newListRef, DatabaseListData list) async {
    await _sharedPreferencesListsNotifier.add(newListRef.key!);
    await newListRef.set(list);
    // state.whenData((value) async {
    //   state = const AsyncValue.loading();
    //   state = await AsyncValue.guard(() async {
    //     await _sharedPreferencesListsNotifier.add(newListRef.key!);
    //     await newListRef.set(list);
    //     return [...value, newListRef];
    //   });
    // });
  }

  Future<void> editList(String listKey, DatabaseListData editedList) async {
    return _listsRef.child(listKey).set(editedList);
  }

  Future<void> removeList(String listKey) async {
    await _listsRef.child(listKey).remove();
    await _tasksRef.child(listKey).remove();
    await _sharedPreferencesListsNotifier.remove(listKey);
    // state.whenData((value) async {
    //   state = const AsyncValue.loading();
    //   state = await AsyncValue.guard(() async {
    //     await _sharedPreferencesListsNotifier.remove(listKey);
    //     await _listsRef.child(listKey).remove();
    //     await _tasksRef.child(listKey).remove();
    //     return value.where((list) => list.key != listKey).toList();
    //   });
    // });
  }

  @override
  Future<List<DatabaseReference>> build() async {
    final SharedPreferencesLists sharedPreferencesLists =
        await ref.watch(sharedPreferencesListsProvider.future);
    return sharedPreferencesLists.lists
        .map((listKey) => _listsRef.child(listKey))
        .toList();
  }
}

final databaseListsReferencesProvider = AutoDisposeAsyncNotifierProvider<
    DatabaseListsReferencesNotifier,
    List<DatabaseReference>>(DatabaseListsReferencesNotifier.new);
