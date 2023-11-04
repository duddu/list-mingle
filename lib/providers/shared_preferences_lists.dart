import 'package:flutter/foundation.dart' show immutable;
import 'package:list_mingle/providers/shared_preferences.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class SharedPreferencesLists {
  const SharedPreferencesLists({required this.lists, required this.activeList});

  final List<String> lists;
  final String? activeList;
}

class SharedPreferencesListsNotifier
    extends AutoDisposeAsyncNotifier<SharedPreferencesLists> {
  Future<SharedPreferencesInstance> _getSharedPreferencesInstance() async =>
      await ref.read(sharedPreferencesInstanceProvider.future);

  Future<void> add(String newId) async {
    state.whenData((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final sharedPreferences = await _getSharedPreferencesInstance();
        final List<String> newLists = [newId, ...value.lists];
        await sharedPreferences.setLists(newLists);
        await sharedPreferences.setActiveList(newId);
        return SharedPreferencesLists(lists: newLists, activeList: newId);
      });
    });
  }

  Future<void> setActive(String newActiveId) async {
    state.whenData((value) async {
      if (newActiveId == value.activeList) {
        return;
      }
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final sharedPreferences = await _getSharedPreferencesInstance();
        await sharedPreferences.setActiveList(newActiveId);
        return SharedPreferencesLists(
            lists: value.lists, activeList: newActiveId);
      });
    });
  }

  Future<void> remove(String removedId) async {
    state.whenData((value) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final List<String> newLists =
            value.lists.where((list) => list != removedId).toList();
        final sharedPreferences = await _getSharedPreferencesInstance();
        await sharedPreferences.setLists(newLists);
        String? activeListId = value.activeList;
        if (removedId == activeListId) {
          activeListId = newLists[0];
          await sharedPreferences.setActiveList(activeListId);
        }
        return SharedPreferencesLists(
            lists: newLists, activeList: activeListId);
      });
    });
  }

  @override
  Future<SharedPreferencesLists> build() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final List<String> lists = sharedPreferences.lists ?? [];
    String? activeList = sharedPreferences.activeList;
    if (lists.isNotEmpty &&
        (activeList == null ||
            activeList.isEmpty ||
            !lists.contains(activeList))) {
      activeList = lists[0];
      await sharedPreferences.setActiveList(activeList);
    }
    return SharedPreferencesLists(lists: lists, activeList: activeList);
  }
}

final sharedPreferencesListsProvider = AutoDisposeAsyncNotifierProvider<
    SharedPreferencesListsNotifier,
    SharedPreferencesLists>(SharedPreferencesListsNotifier.new);
