import 'package:flutter/material.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class ModernScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? endDrawer;

  const ModernScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.extendBodyBehindAppBar = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topInset =
        extendBodyBehindAppBar
            ? MediaQuery.of(context).padding.top + kToolbarHeight
            : 0.0;
    final content =
        extendBodyBehindAppBar
            ? Padding(padding: EdgeInsets.only(top: topInset), child: body)
            : body;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      endDrawer: endDrawer,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withOpacity(0.95),
                scheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AppBackground(child: content),
    );
  }
}
