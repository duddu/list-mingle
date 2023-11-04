import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/providers/view_active_list.dart';
import 'package:list_mingle/providers/view_lists.dart';

class DeleteActiveList extends HookConsumerWidget {
  const DeleteActiveList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ViewListModel> list = ref.watch(viewActiveListProvider);

    return list.maybeWhen(
        data: (value) => IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () {
              ref.read(viewListsProvider.notifier).remove(value.id);
            }),
        orElse: () => const SizedBox(width: 0, height: 0));
  }
}
