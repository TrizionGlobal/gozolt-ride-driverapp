import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

class GozoltDriverApp extends ConsumerWidget {
  const GozoltDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return RootRestorationScope(
      restorationId: 'root',
      child: MaterialApp.router(
        title: 'Gozolt Driver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final isDark = themeMode == ThemeMode.dark || 
            (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        final iconBrightness = isDark ? Brightness.light : Brightness.dark;
        
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: iconBrightness,
            systemNavigationBarIconBrightness: iconBrightness,
          ),
          child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
