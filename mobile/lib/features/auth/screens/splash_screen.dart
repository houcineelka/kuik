import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_service.dart';
import '../../../core/models/user.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../widgets/shared/skyline_illustration.dart';
import '../providers/auth_providers.dart';

/// Checks for a persisted session and routes to Home or Login once
/// resolved. [authControllerProvider.build] does the actual token check.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Prompt for location access as soon as the app opens, rather than
    // waiting for the user to reach a screen that needs it.
    ref.read(locationServiceProvider).resolveCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) => context.go(user != null ? '/home' : '/login'),
      );
    });

    // Ensure evaluation starts even if nothing else has read the provider yet.
    ref.watch(authControllerProvider);

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkylineIllustration(size: 150, pinColor: scheme.primary),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: textTheme.headlineMedium,
                children: [
                  TextSpan(text: 'Kuik', style: TextStyle(color: scheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.splashTagline,
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: scheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
