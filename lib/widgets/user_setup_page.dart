import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/shared_preferences_user.dart';

class UserSetupPage extends HookConsumerWidget {
  const UserSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferencesUserNotifier =
        ref.read(sharedPreferencesUserProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Pick your name',
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
                          'This name will be displayed only to the people you decide to share your lists with.',
                          style: Theme.of(context).textTheme.bodyMedium)),
                  TextField(
                    autofocus: true,
                    maxLength: 25,
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
                        sharedPreferencesUserNotifier.set(name);
                      }
                    },
                  )
                ])));
  }
}
