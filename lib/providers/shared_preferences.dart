import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const userIdStorageKey = '74dba2a6a0c6';
const userNameStorageKey = '2a6dfc4e49ad';
const listsStorageKey = '3b084549c2df';
const activeListStorageKey = '5ee49e9ba0e1';

@immutable
class SharedPreferencesInstance {
  const SharedPreferencesInstance(this.instance);

  final SharedPreferences instance;

  T? _getValue<T>(String key) {
    final String? value = instance.getString(key);
    if (value == null) {
      return null;
    }
    final String decodedValue = utf8.decode(base64.decode(value));
    if (key == listsStorageKey) {
      return decodedValue.split(',') as T;
    }
    return decodedValue as T;
  }

  String? get userId => _getValue<String>(userIdStorageKey);
  String? get userName => _getValue<String>(userNameStorageKey);
  List<String>? get lists => _getValue<List<String>>(listsStorageKey);
  String? get activeList => _getValue<String>(activeListStorageKey);

  Future<void> _setValueOrThrow(String key, dynamic value) async {
    if (value == null) {
      throw ArgumentError.notNull('value');
    }
    if (value is! String && value is! List<String>) {
      throw ArgumentError.value(value, 'value');
    }
    if (value is List<String>) {
      value = value.join(',');
    }
    final String encodedValue = base64.encode(utf8.encode(value));
    final bool success = await instance.setString(key, encodedValue);
    if (!success) {
      throw Exception('Unable to store $key');
    }
  }

  Future<void> setUserId(String uid) => _setValueOrThrow(userIdStorageKey, uid);
  Future<void> setUserName(String name) =>
      _setValueOrThrow(userNameStorageKey, name);
  Future<void> setLists(lists) => _setValueOrThrow(listsStorageKey, lists);
  Future<void> setActiveList(String activeList) =>
      _setValueOrThrow(activeListStorageKey, activeList);
}

final sharedPreferencesInstanceProvider =
    FutureProvider<SharedPreferencesInstance>((ref) async {
  SharedPreferences.setPrefix('list-mingle-');
  return SharedPreferencesInstance(await SharedPreferences.getInstance());
});
