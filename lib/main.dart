// import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_mingle/config/firebase_options.dart';
import 'package:list_mingle/config/theme.dart';
import 'package:list_mingle/providers/shared_preferences_user.dart';
import 'package:list_mingle/providers/view_lists.dart';
import 'package:list_mingle/widgets/first_list_page.dart';
import 'package:list_mingle/widgets/loading_page.dart';
import 'package:list_mingle/widgets/tasks_page.dart';
import 'package:list_mingle/widgets/user_setup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name: Platform.operatingSystem,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const ProviderScope(child: ListMingle()));
}

class ListMingle extends HookConsumerWidget {
  const ListMingle({super.key});

  // PageRouteBuilder _getPageRouteBuilder(RouteSettings settings, Widget page) {
  //   return PageRouteBuilder(
  //       settings: settings,
  //       pageBuilder: (context, animation, secondaryAnimation) => page,
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         const begin = Offset(1.0, 0.0);
  //         const end = Offset.zero;
  //         const curve = Curves.ease;
  //         final tween =
  //             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  //         return SlideTransition(
  //           position: animation.drive(tween),
  //           child: child,
  //         );
  //       });
  // }

  // Route _onGenerateRoute(RouteSettings settings, Widget homeWidget) {
  //   switch (settings.name) {
  //     case '/':
  //       return _getPageRouteBuilder(settings, homeWidget);
  //     default:
  //       return MaterialPageRoute(builder: (context) => homeWidget);
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferencesUser = ref.watch(sharedPreferencesUserProvider);
    final viewLists = ref.watch(viewListsProvider);

    final Widget homeWidget = switch (sharedPreferencesUser) {
      AsyncData(:final value) => value == null
          ? const UserSetupPage()
          : (viewLists.valueOrNull != null && viewLists.valueOrNull!.isNotEmpty)
              ? const TasksPage()
              : switch (viewLists) {
                  AsyncData(:final value) =>
                    value.isNotEmpty ? const TasksPage() : const NewListPage(),
                  AsyncError(:final error) => Text('Error: $error'),
                  _ => const LoadingPage()
                },
      AsyncError(:final error) => Text('Error: $error'),
      _ => const LoadingPage()
    };

    return MaterialApp(
        title: 'ListMingle', theme: appThemeData, home: homeWidget);
  }
}
