import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kDebugMode, immutable;
import 'package:flutter/material.dart';
import 'package:list_mingle/providers/database_tasks_reference.dart';
import 'package:list_mingle/providers/database_tasks_events.dart';
import 'package:list_mingle/providers/shared_preferences_user.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class ViewTaskModel extends DatabaseTaskModel {
  const ViewTaskModel({
    required this.id,
    required super.title,
    required super.author,
    required super.timestamp,
    super.completed,
    super.notes,
  });

  final String id;

  factory ViewTaskModel.fromDatabaseTaskSnapshot(DataSnapshot snapshot) {
    try {
      final String id = snapshot.key!;
      final DatabaseTaskData value = snapshot.value! as DatabaseTaskData;
      return ViewTaskModel(
          id: id,
          title: value['title'] as String,
          author: value['author'] as String,
          timestamp: value['timestamp'] as int,
          completed: value['completed'] as bool,
          notes: value['notes'] == null || (value['notes'] as String).isEmpty
              ? null
              : value['notes'] as String);
    } catch (e) {
      throw FormatException(
          e.toString(), '${snapshot.key}=${snapshot.value.toString()}');
    }
  }
}

enum TaskStatus { active, completed }

typedef RemovedTaskBuilder<T> = Widget Function(
    T task,
    int index,
    ViewTasksNotifier notifier,
    BuildContext context,
    Animation<double> animation);

class ViewTasksNotifier extends AutoDisposeAsyncNotifier<List<ViewTaskModel>> {
  ViewTasksNotifier(this._taskStatusFilter, this._removedTaskBuilder);

  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final TaskStatus _taskStatusFilter;
  final RemovedTaskBuilder<ViewTaskModel> _removedTaskBuilder;

  AnimatedListState? get _animatedList => _listKey.currentState;
  DatabaseTasksReferenceNotifier get _tasksRefNotifier =>
      ref.read(databaseTasksReferenceProvider.notifier);

  GlobalKey<AnimatedListState> getListKey() => _listKey;

  void _handleViewTaskInsert(ViewTaskModel insertedTask) {
    state.whenData((value) {
      state = AsyncValue.data([insertedTask, ...value]);
      _animatedList?.insertItem(0);
    });
  }

  void _handleViewTaskEdit(ViewTaskModel editedTask) {
    state.whenData((value) {
      state = AsyncValue.data(value
          .map((task) => task.id == editedTask.id ? editedTask : task)
          .toList());
    });
  }

  void _handleViewTaskRemove(ViewTaskModel removedTask, int index,
      [Widget Function(BuildContext, Animation<double>)? removeBuilder]) {
    state.whenData((value) {
      state = AsyncValue.data(
          value.where((task) => task.id != removedTask.id).toList());
      _animatedList?.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        if (removeBuilder != null) {
          return removeBuilder(context, animation);
        }
        return _removedTaskBuilder(
            removedTask, index, this, context, animation);
      });
    });
  }

  bool _meetsTaskStatusFilter(ViewTaskModel task) {
    if (_taskStatusFilter == TaskStatus.active && task.completed == true) {
      return false;
    }
    if (_taskStatusFilter == TaskStatus.completed && task.completed == false) {
      return false;
    }
    return true;
  }

  Future<void> insert(String title) async {
    final DatabaseReference newTaskRef = _tasksRefNotifier.getNewTaskRef();
    final SharedPreferencesUser? user =
        await ref.read(sharedPreferencesUserProvider.future);
    final ViewTaskModel newLocalTask = ViewTaskModel(
        id: newTaskRef.key!,
        title: title,
        author: user?.name ?? 'Unknown',
        timestamp: DateTime.now().microsecondsSinceEpoch);
    _handleViewTaskInsert(newLocalTask);
    _tasksRefNotifier.addTask(newTaskRef, newLocalTask.toDatabaseTaskData());
  }

  Future<void> edit(ViewTaskModel task,
      {String? title, bool? completed, String? notes}) async {
    final SharedPreferencesUser? user =
        await ref.read(sharedPreferencesUserProvider.future);
    final ViewTaskModel editedLocalTask = ViewTaskModel(
        id: task.id,
        title: title == null || title.isEmpty ? task.title : title,
        completed: completed ?? task.completed,
        notes: notes == null || notes.isEmpty ? task.notes : notes,
        author: user?.name ?? 'Unknown',
        timestamp: DateTime.now().microsecondsSinceEpoch);
    _handleViewTaskEdit(editedLocalTask);
    _tasksRefNotifier.editTask(task.id, editedLocalTask.toDatabaseTaskData());
  }

  ViewTaskModel remove(ViewTaskModel removedTask, int index,
      [Widget Function(BuildContext, Animation<double>)? removeBuilder]) {
    _handleViewTaskRemove(removedTask, index, removeBuilder);
    _tasksRefNotifier.removeTask(removedTask.id);
    return removedTask;
  }

  bool _isOrphanedCallback() {
    if (ref.exists(databaseTasksReferenceProvider)) {
      return false;
    }
    return true;
  }

  void _onDatabaseTaskAddedCallback(_, AsyncValue<DatabaseEvent> event) {
    if (kDebugMode && _isOrphanedCallback()) {
      return;
    }
    if (!event.hasValue ||
        event.value?.snapshot.key == null ||
        event.value?.snapshot.value == null) {
      return;
    }
    final ViewTaskModel newTask =
        ViewTaskModel.fromDatabaseTaskSnapshot(event.value!.snapshot);
    if (!_meetsTaskStatusFilter(newTask)) {
      return;
    }
    state.whenData((state) {
      if (state.indexWhere((task) => task.id == newTask.id) != -1) {
        return;
      }
      _handleViewTaskInsert(newTask);
    });
  }

  void _onDatabaseTaskChangedCallback(_, AsyncValue<DatabaseEvent> event) {
    if (kDebugMode && _isOrphanedCallback()) {
      return;
    }
    if (!event.hasValue ||
        event.value?.snapshot.key == null ||
        event.value?.snapshot.value == null) {
      return;
    }
    final ViewTaskModel changedTask =
        ViewTaskModel.fromDatabaseTaskSnapshot(event.value!.snapshot);
    state.whenData((state) {
      final index = state.indexWhere((task) => task.id == changedTask.id);
      if (_meetsTaskStatusFilter(changedTask) && index == -1) {
        _handleViewTaskInsert(changedTask);
        return;
      }
      if (!_meetsTaskStatusFilter(changedTask) && index != -1) {
        _handleViewTaskRemove(changedTask, index);
        return;
      }
      _handleViewTaskEdit(changedTask);
    });
  }

  void _onDatabaseTaskRemovedCallback(_, AsyncValue<DatabaseEvent> event) {
    if (kDebugMode && _isOrphanedCallback()) {
      return;
    }
    if (!event.hasValue) {
      return;
    }
    state.whenData((state) {
      final index =
          state.indexWhere((task) => task.id == event.value?.snapshot.key);
      if (index == -1) {
        return;
      }
      ViewTaskModel removedTask = state.elementAt(index);
      _handleViewTaskRemove(removedTask, index);
    });
  }

  void _initializeDatabaseStreamListeners() {
    ref.listen<AsyncValue<DatabaseEvent>>(
        databaseTaskAddedEventProvider, _onDatabaseTaskAddedCallback);
    ref.listen<AsyncValue<DatabaseEvent>>(
        databaseTaskChangedEventProvider, _onDatabaseTaskChangedCallback);
    ref.listen<AsyncValue<DatabaseEvent>>(
        databaseTaskRemovedEventProvider, _onDatabaseTaskRemovedCallback);
  }

  @override
  Future<List<ViewTaskModel>> build() async {
    await ref.watch(databaseTasksReferenceProvider.future);
    _initializeDatabaseStreamListeners();
    _listKey = GlobalKey();
    return [];
  }
}
