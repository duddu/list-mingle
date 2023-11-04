import 'package:flutter/foundation.dart' show immutable;
import 'package:list_mingle/providers/shared_preferences.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

@immutable
class SharedPreferencesUser {
  const SharedPreferencesUser({required this.id, required this.name});

  final String id;
  final String name;
}

class SharedPreferencesUserNotifier
    extends AutoDisposeAsyncNotifier<SharedPreferencesUser?> {
  Future<SharedPreferencesInstance> _getSharedPreferencesInstance() async =>
      await ref.read(sharedPreferencesInstanceProvider.future);

  Future<void> set(String name) async {
    if (name.isEmpty) {
      return;
    }
    state.whenData((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final sharedPreferences = await _getSharedPreferencesInstance();
        final String uid = const Uuid().v4();
        await sharedPreferences.setUserId(uid);
        await sharedPreferences.setUserName(name);
        return SharedPreferencesUser(id: uid, name: name);
      });
    });
  }

  @override
  Future<SharedPreferencesUser?> build() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    String? uid = sharedPreferences.userId;
    String? name = sharedPreferences.userName;
    if (uid == null || name == null) {
      return null;
    }
    return SharedPreferencesUser(id: uid, name: name);
  }
}

final sharedPreferencesUserProvider = AutoDisposeAsyncNotifierProvider<
    SharedPreferencesUserNotifier,
    SharedPreferencesUser?>(SharedPreferencesUserNotifier.new);
