import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/view_lists.dart';

class NewListPage extends HookConsumerWidget {
  const NewListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(viewListsProvider);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Create your first list',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: basePadding),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Text(
                          'Choose a name for your first list, e.g. Groceries 🛒',
                          style: Theme.of(context).textTheme.bodyMedium)),
                  TextField(
                    autofocus: true,
                    maxLength: 50,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: basePadding),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.secondary),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(baseRadius))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.secondary),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(baseRadius)))),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onSubmitted: (String name) {
                      if (name.isNotEmpty) {
                        ref.read(viewListsProvider.notifier).insert(name);
                      }
                    },
                  )
                ])));
  }
}
