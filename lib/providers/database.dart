import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod/riverpod.dart';

final databaseInstanceProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});
