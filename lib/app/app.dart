import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router/app_router.dart';
import 'theme/theme.dart';

/// The root of the WorkSettle candidate app.
class WorkSettleApp extends ConsumerWidget {
  const WorkSettleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WorkSettle',
      debugShowCheckedModeBanner: false,
      theme: WorkSettleTheme.light,
      darkTheme: WorkSettleTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // The design system asks for 200% text scaling support (section 21).
        // Cards grow; they do not clip. We clamp only the runaway end, where
        // no layout survives.
        final scale = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 2.0,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
