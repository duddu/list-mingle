import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/view_tasks.dart';

class TaskTile extends HookConsumerWidget {
  const TaskTile({
    required super.key,
    required this.index,
    required this.task,
    required this.animation,
    required this.tasksNotifier,
    this.isBeingRemoved = false,
  });

  final int index;
  final ViewTaskModel task;
  final Animation<double> animation;
  final ViewTasksNotifier tasksNotifier;
  final bool isBeingRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = useState(false);

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 1,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 4, horizontal: basePadding),
        child: SizedBox(
            height: taskHeight,
            child: Dismissible(
                key: ValueKey<String>(task.id),
                dragStartBehavior: DragStartBehavior.start,
                onDismissed: (direction) {
                  tasksNotifier.remove(
                      task,
                      index,
                      (context, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: const SizedBox(width: 0, height: taskHeight)));
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(basePadding, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: (task.completed && !isBeingRemoved) ||
                              (!task.completed && isBeingRemoved)
                          // ? Theme.of(context).colorScheme.inverseSurface
                          ? Colors.grey.shade200
                          : Colors.white,
                      border: Border.all(
                          width: 1,
                          color: isEditing.value
                              ? Theme.of(context).colorScheme.secondary
                              : task.completed || isBeingRemoved
                                  ? Colors.grey.shade200
                                  : Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(baseRadius)),
                    ),
                    child: isEditing.value
                        ? TaskTileEditingContent(
                            task: task,
                            tasksNotifier: tasksNotifier,
                            isEditing: isEditing)
                        : TaskTileViewingContent(
                            task: task,
                            tasksNotifier: tasksNotifier,
                            isEditing: isEditing)))),
      ),
    );
  }
}

class TaskTileViewingContent extends HookWidget {
  const TaskTileViewingContent(
      {super.key,
      required this.task,
      required this.tasksNotifier,
      required this.isEditing});

  final ViewTaskModel task;
  final ViewTasksNotifier tasksNotifier;
  final ValueNotifier<bool> isEditing;

  @override
  Widget build(BuildContext context) {
    final isCompleted = useState(task.completed);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Transform.scale(
                scale: 1.4,
                alignment: Alignment.center,
                origin: const Offset(8, 0),
                child: Checkbox(
                  value: isCompleted.value,
                  onChanged: (value) {
                    isCompleted.value = !isCompleted.value;
                    if (isCompleted.value != task.completed) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        tasksNotifier.edit(task, completed: isCompleted.value);
                      });
                    }
                  },
                  shape: const CircleBorder(),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      width: 1),
                  activeColor: Theme.of(context).colorScheme.secondary,
                ))),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text.rich(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.merge(TextStyle(
                  color: isCompleted.value ? Colors.black54 : Colors.black87)),
              TextSpan(
                  text: task.title,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      isEditing.value = true;
                    })),
        )),
      ]),
    ]);
  }
}

class TaskTileEditingContent extends HookWidget {
  const TaskTileEditingContent(
      {super.key,
      required this.task,
      required this.tasksNotifier,
      required this.isEditing});

  final ViewTaskModel task;
  final ViewTasksNotifier tasksNotifier;
  final ValueNotifier<bool> isEditing;

  void _submit(String text) {
    if (text.isNotEmpty && text != task.title) {
      tasksNotifier.edit(task, title: text);
    }
    isEditing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: task.title);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(3, 0, 13, 0),
            child: Icon(
              Icons.edit_rounded,
              color: Theme.of(context).colorScheme.secondary,
            )),
        Expanded(
            child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 18.5),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.merge(TextStyle(
                    color: task.completed
                        ? Colors.grey.shade700
                        : Colors.black87)),
                onSubmitted: _submit)),
        IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: task.completed ? Colors.grey.shade700 : Colors.grey.shade800,
          ),
          padding: const EdgeInsets.all(4),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            controller.text = task.title;
            isEditing.value = false;
          },
        ),
        // IconButton(
        //   icon: Icon(
        //     Icons.done_rounded,
        //     color: Colors.grey.shade800,
        //   ),
        //   padding: const EdgeInsets.all(5),
        //   visualDensity: VisualDensity.compact,
        //   onPressed: () {
        //     _submit(controller.text);
        //   },
        // )
      ])
    ]);
  }
}
