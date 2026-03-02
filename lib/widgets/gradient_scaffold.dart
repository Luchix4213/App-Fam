import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';

class GradientScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final Widget? drawer;
  final Key? scaffoldKey;

  const GradientScaffold({
    Key? key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appColores.gradientTop,
            Colors.white,
            appColores.gradientBottom,
          ],
          stops: [0.0, 0.5, 1.0], // White in the middle for a clean look
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent, // Important!
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      ),
    );
  }
}
