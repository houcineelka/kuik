import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/locale_provider.dart';
import 'core/notifications/notification_navigation.dart';
import 'features/claims/providers/claims_provider.dart';
import 'features/conversations/providers/conversations_provider.dart';
import 'features/matches/providers/matches_provider.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/theme.dart';

class KuikApp extends ConsumerStatefulWidget {
  const KuikApp({super.key});

  @override
  ConsumerState<KuikApp> createState() => _KuikAppState();
}

class _KuikAppState extends ConsumerState<KuikApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A push can be missed while backgrounded (process killed, OEM battery
    // restrictions) — refetching whenever the app comes back to the
    // foreground means claims/matches/conversations are never more than a
    // resume away from correct, with no manual pull-to-refresh needed.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(claimsControllerProvider);
      ref.invalidate(matchesControllerProvider);
      ref.invalidate(conversationsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    ref.watch(notificationNavigationProvider);

    return MaterialApp.router(
      title: 'KuikMaroc',
      debugShowCheckedModeBanner: false,
      theme: LedgerTheme.light(),
      darkTheme: LedgerTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
