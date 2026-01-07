import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenWrapper extends StatelessWidget {
  final Widget child;
  const FullscreenWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // FIX: Instead of setEnabledSystemUIOverlays, we use setEnabledSystemUIMode
    // 'immersiveSticky' hides the bars, but they auto-hide again after a swipe.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: [SystemUiOverlay.top], // This keeps only the status bar (clock) visible
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return child;
  }
}