import 'package:flutter/material.dart';
import 'loading_indicator.dart';

/// Scaffold com suporte a estado de loading integrado.
///
/// Exibe um [LoadingIndicator] centralizado enquanto [isLoading] for true.
/// Quando [isLoading] for false, exibe o [body] normalmente.
///
/// O [floatingActionButton] é automaticamente ocultado durante o loading.
class LoadingScaffold extends StatelessWidget {
  final bool isLoading;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final double? drawerEdgeDragWidth;
  final void Function(bool)? onDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;

  const LoadingScaffold({
    super.key,
    required this.isLoading,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.drawerEdgeDragWidth,
    this.onDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      onDrawerChanged: onDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      floatingActionButton: isLoading ? null : floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: isLoading ? const LoadingIndicator() : body,
    );
  }
}
