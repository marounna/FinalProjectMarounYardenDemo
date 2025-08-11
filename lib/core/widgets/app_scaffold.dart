import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBack; // when true, show back if navigator can pop

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop(); // go_router extension
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack && canPop
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottom == null ? null : SafeArea(child: bottom!),
    );
  }
}
