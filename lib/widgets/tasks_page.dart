import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/widgets/active_list_header.dart';
import 'package:list_mingle/widgets/add_task.dart';
import 'package:list_mingle/widgets/delete_active_list.dart';
import 'package:list_mingle/widgets/lists_drawer.dart';
import 'package:list_mingle/widgets/tasks.dart';

class TasksPage extends HookWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isEditingActiveList = useState(false);

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  isEditingActiveList.value = true;
                }),
            const DeleteActiveList(),
            IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  throw UnimplementedError();
                }),
          ],
        ),
        body: Column(children: [
          Row(children: [
            Expanded(child: ListHeader(isEditing: isEditingActiveList))
          ]),
          Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(baseRadius)),
                          color: Theme.of(context).colorScheme.background),
                      child: ListView(
                          primary: true,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                          children: [
                            Tasks(
                                tasksProvider: activeTasksProvider,
                                emptyListMessage: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        basePadding + 2,
                                        basePadding * 2,
                                        basePadding + 2,
                                        0),
                                    child: Center(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                          Text('No active items in this list',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          Text(
                                              'Tap the button below to create a new one',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall)
                                        ])))),
                            Tasks(
                              tasksProvider: completedTasksProvider,
                              title: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      basePadding + 2, 28, basePadding + 2, 0),
                                  child: Text('Completed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall)),
                            ),
                          ]))))
        ]),
        floatingActionButton: const AddTask(),
        drawer: const ListsDrawer());
  }
}
