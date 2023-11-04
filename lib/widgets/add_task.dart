import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/widgets/tasks.dart';

class AddTask extends HookConsumerWidget {
  const AddTask({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final ValueNotifier<double> endTween = useState(0);

    final bool isExtended = endTween.value == 100;
    final double widthPercent =
        (MediaQuery.of(context).size.width - basePadding * 2 - taskHeight)
                .abs() /
            100;

    return Padding(
        padding: const EdgeInsets.only(left: basePadding * 2),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: endTween.value),
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 750),
          builder: (BuildContext context, double progress, Widget? child) {
            double radius =
                ((basePadding - (taskHeight / 2)) / 100) * progress +
                    (taskHeight / 2);
            return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade600,
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, 1))
                  ]),
              height: taskHeight,
              width: taskHeight + widthPercent * progress,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isExtended)
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: progress > 50 ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(18, 0, 18, 2),
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.merge(TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontWeight: FontWeight.w600)),
                            hintText: 'Type here',
                            border: InputBorder.none,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.merge(
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          onSubmitted: (String text) {
                            if (text.isEmpty) {
                              return;
                            }
                            ref.read(activeTasksProvider.notifier).insert(text);
                            controller.text = '';
                          },
                        ),
                      ),
                    ),
                  Transform.rotate(
                      angle: (3 / 4 * math.pi / 100) * progress,
                      child: IconButton(
                        padding: const EdgeInsets.all(17),
                        iconSize: 28,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          endTween.value = isExtended ? 0 : 100;
                          if (isExtended) {
                            controller.text = '';
                          }
                        },
                      )),
                ],
              ),
            );
          },
        ));
  }
}
