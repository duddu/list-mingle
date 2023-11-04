import 'package:firebase_database/firebase_database.dart';
import 'package:list_mingle/providers/database_tasks_reference.dart';
import 'package:riverpod/riverpod.dart';

final databaseTaskAddedEventProvider =
    AutoDisposeStreamProvider<DatabaseEvent>((ref) async* {
  final DatabaseReference tasksRef =
      await ref.watch(databaseTasksReferenceProvider.future);
  yield* tasksRef.onChildAdded.asBroadcastStream();
});

final databaseTaskChangedEventProvider =
    AutoDisposeStreamProvider<DatabaseEvent>((ref) async* {
  final DatabaseReference tasksRef =
      await ref.watch(databaseTasksReferenceProvider.future);
  yield* tasksRef.onChildChanged.asBroadcastStream();
});

final databaseTaskRemovedEventProvider =
    AutoDisposeStreamProvider<DatabaseEvent>((ref) async* {
  final DatabaseReference tasksRef =
      await ref.watch(databaseTasksReferenceProvider.future);
  yield* tasksRef.onChildRemoved.asBroadcastStream();
});
