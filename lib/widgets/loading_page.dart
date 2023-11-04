import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingBar());
  }
}

class LoadingBar extends StatelessWidget {
  const LoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 10, child: LinearProgressIndicator(minHeight: 10));
  }
}
