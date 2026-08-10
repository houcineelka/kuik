import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/models/user.dart';
import 'package:mobile/core/notifications/notification_navigation.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';

class _FakeLoggedOutController extends AuthController {
  @override
  Future<User?> build() async => null;
}

void main() {
  testWidgets('Splash routes to Login when no session is stored', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_FakeLoggedOutController.new),
          // Firebase isn't initialized in the test environment.
          notificationNavigationProvider.overrideWithValue(null),
        ],
        child: const KuikApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
