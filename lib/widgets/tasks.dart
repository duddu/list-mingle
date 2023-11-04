import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/view_tasks.dart';
import 'package:list_mingle/widgets/task_tile.dart';

TaskTile _buildTaskTile(ViewTaskModel task, int index,
        ViewTasksNotifier taskNotifier, Animation<double> animation,
        [bool isBeingRemoved = false]) =>
    TaskTile(
        key: ValueKey<String>(task.id),
        index: index,
        task: task,
        tasksNotifier: taskNotifier,
        animation: animation,
        isBeingRemoved: isBeingRemoved);

Widget _buildRemovedTaskTile(
    ViewTaskModel removedItem,
    int index,
    ViewTasksNotifier taskNotifier,
    BuildContext context,
    Animation<double> animation) {
  return _buildTaskTile(removedItem, index, taskNotifier, animation, true);
}

final activeTasksProvider =
    AutoDisposeAsyncNotifierProvider<ViewTasksNotifier, List<ViewTaskModel>>(
        () => ViewTasksNotifier(TaskStatus.active, _buildRemovedTaskTile));

final completedTasksProvider =
    AutoDisposeAsyncNotifierProvider<ViewTasksNotifier, List<ViewTaskModel>>(
        () => ViewTasksNotifier(TaskStatus.completed, _buildRemovedTaskTile));

class Tasks extends HookConsumerWidget {
  const Tasks(
      {super.key,
      required this.tasksProvider,
      this.title,
      this.emptyListMessage});

  final AutoDisposeAsyncNotifierProvider<ViewTasksNotifier, List<ViewTaskModel>>
      tasksProvider;
  final Widget? title;
  final Widget? emptyListMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    useAutomaticKeepAlive(wantKeepAlive: true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && tasks.value != null && tasks.value!.isNotEmpty)
          title!,
        if (tasks.value != null)
          emptyListMessage != null && tasks.value!.isEmpty
              ? emptyListMessage!
              : Flexible(
                  child: AnimatedList(
                    key: ref.read(tasksProvider.notifier).getListKey(),
                    initialItemCount: tasks.value!.length,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      final item = tasks.value!.elementAt(index);
                      return _buildTaskTile(item, index,
                          ref.read(tasksProvider.notifier), animation);
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    padding: tasks.value!.isNotEmpty
                        ? const EdgeInsets.only(top: basePadding)
                        : null,
                    shrinkWrap: true,
                  ),
                )
      ],
    );
  }
}
