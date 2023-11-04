import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/view_lists.dart';
import 'package:list_mingle/widgets/loading_page.dart';

class ListsDrawer extends HookConsumerWidget {
  const ListsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ViewListModel>> lists = ref.read(viewListsProvider);

    final ValueNotifier<int?> selectedIndex = useState(null);
    final ValueNotifier<bool> isInsertingList = useState(false);

    useEffect(() {
      if (lists.valueOrNull != null) {
        selectedIndex.value = lists.value?.indexWhere((list) => list.active);
      }
      return;
    }, [lists.valueOrNull]);

    return switch (lists) {
      AsyncData(:final value) => NavigationDrawer(
            onDestinationSelected: (index) {
              Future.delayed(const Duration(milliseconds: 80), () {
                if (index == value.length) {
                  isInsertingList.value = true;
                  return;
                } else if (index != selectedIndex.value) {
                  ref
                      .read(viewListsProvider.notifier)
                      .setActive(value.elementAt(index).id);
                }
                Navigator.pop(context);
              });
            },
            selectedIndex: selectedIndex.value,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(
                      28, basePadding, basePadding, 10),
                  child: Text(
                    'Lists',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
              ...value.map((list) => NavigationDrawerDestination(
                  icon: const Icon(Icons.list_rounded),
                  label: Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: basePadding),
                          child: Text(
                            list.name,
                            overflow: TextOverflow.ellipsis,
                          ))))),
              const ListsDrawerDivider(),
              isInsertingList.value
                  ? ListsDrawerInsertList(
                      isInsertingList: isInsertingList,
                    )
                  : const NavigationDrawerDestination(
                      icon: Icon(Icons.add_rounded),
                      label: Text('Create new list')),
              const ListsDrawerDivider(),
            ]),
      AsyncError(:final error) =>
        NavigationDrawer(children: [Text('Error: $error')]),
      _ => const NavigationDrawer(children: [
          Row(children: [Expanded(child: LoadingBar())])
        ]),
    };
  }
}

class ListsDrawerInsertList extends HookConsumerWidget {
  const ListsDrawerInsertList({super.key, required this.isInsertingList});

  final ValueNotifier<bool> isInsertingList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController newListNameController =
        useTextEditingController();

    void submit(String listName) {
      if (listName.isNotEmpty) {
        ref.read(viewListsProvider.notifier).insert(listName);
        Navigator.pop(context);
      }
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
        child: Column(children: [
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.grey.shade800,
                )),
            Expanded(
                child: TextField(
              autofocus: true,
              controller: newListNameController,
              maxLength: 40,
              style: Theme.of(context).textTheme.titleSmall,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 2),
                hintText: 'New list name',
                border: InputBorder.none,
              ),
              onSubmitted: submit,
            )),
            IconButton(
              padding: const EdgeInsets.all(5),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade800,
                size: 20,
              ),
              onPressed: () {
                newListNameController.text = '';
                isInsertingList.value = false;
              },
            ),
            // IconButton(
            //   padding: const EdgeInsets.all(5),
            //   visualDensity: VisualDensity.compact,
            //   icon: Icon(
            //     Icons.done_rounded,
            //     color: Colors.grey.shade800,
            //     size: 20,
            //   ),
            //   onPressed: () {
            //     submit(newListNameController.text);
            //   },
            // )
          ])
        ]));
  }
}

class ListsDrawerDivider extends StatelessWidget {
  const ListsDrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Divider(),
    );
  }
}
