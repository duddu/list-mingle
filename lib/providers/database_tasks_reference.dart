import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:list_mingle/providers/database.dart';
import 'package:list_mingle/providers/view_active_list.dart';
import 'package:list_mingle/providers/view_lists.dart';
import 'package:riverpod/riverpod.dart';

typedef DatabaseTaskData = Map<String, dynamic>;

@immutable
class DatabaseTaskModel {
  const DatabaseTaskModel({
    required this.title,
    required this.author,
    required this.timestamp,
    this.completed = false,
    this.notes,
  });

  final String title;
  final String author;
  final int timestamp;
  final bool completed;
  final String? notes;

  DatabaseTaskData toDatabaseTaskData() => {
        'title': title,
        'author': author,
        'timestamp': timestamp,
        'completed': completed,
        'notes': notes,
      };
}

class DatabaseTasksReferenceNotifier
    extends AutoDisposeAsyncNotifier<DatabaseReference> {
  DatabaseReference get _tasksRef =>
      ref.read(databaseInstanceProvider).ref('tasks');

  DatabaseReference getNewTaskRef() => state.requireValue.push();

  Future<void> addTask(DatabaseReference newTaskRef, DatabaseTaskData task) =>
      newTaskRef.set(task);

  Future<void> editTask(String taskKey, DatabaseTaskData editedTask) async {
    state.whenData((value) {
      value.child(taskKey).set(editedTask);
    });
  }

  Future<void> removeTask(String taskKey) async {
    state.whenData((value) {
      value.child(taskKey).remove();
    });
  }

  @override
  Future<DatabaseReference> build() async {
    final ViewListModel viewActiveList =
        await ref.watch(viewActiveListProvider.future);
    return _tasksRef.child(viewActiveList.id);
  }
}

final databaseTasksReferenceProvider = AutoDisposeAsyncNotifierProvider<
    DatabaseTasksReferenceNotifier,
    DatabaseReference>(DatabaseTasksReferenceNotifier.new);
