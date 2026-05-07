import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemOverlayWrapper extends StatelessWidget {
  final Widget child;
  const SystemOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: child,
    );
  }
}