import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/view_active_list.dart';
import 'package:list_mingle/providers/view_lists.dart';

class ListHeader extends HookConsumerWidget {
  const ListHeader({super.key, required this.isEditing});

  final ValueNotifier<bool> isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ViewListModel> list = ref.watch(viewActiveListProvider);

    return switch (list) {
      AsyncData(:final value) => isEditing.value
          ? Container(
              padding: const EdgeInsets.fromLTRB(
                  basePadding + 2, 0, basePadding + 2, 12),
              color: Theme.of(context).colorScheme.primary,
              child: TextField(
                controller: TextEditingController(text: value.name),
                autofocus: true,
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 2),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineLarge,
                onSubmitted: (String text) {
                  if (text.isNotEmpty && text != value.name) {
                    ref.read(viewListsProvider.notifier).edit(value.id, text);
                  }
                  isEditing.value = false;
                },
              ))
          : Container(
              padding: const EdgeInsets.fromLTRB(
                  basePadding + 2, 4, basePadding + 2, basePadding + 2),
              color: Theme.of(context).colorScheme.primary,
              child: Text(value.name,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headlineLarge)),
      AsyncError(:final error) => Text('Error: $error'),
      _ => Text('', style: Theme.of(context).textTheme.headlineLarge),
    };
  }
}
