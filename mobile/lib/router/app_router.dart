import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/claims/screens/claims_screen.dart';
import '../features/conversations/screens/chat_screen.dart';
import '../features/conversations/screens/conversations_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/listings/screens/declare_listing_screen.dart';
import '../features/listings/screens/listing_detail_screen.dart';
import '../features/listings/screens/listings_list_screen.dart';
import '../features/matches/screens/matches_screen.dart';
import 'transitions.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => ledgerPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => ledgerPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => ledgerPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => ledgerPage(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/declare',
        pageBuilder: (context, state) => ledgerPage(state, const DeclareListingScreen()),
      ),
      GoRoute(
        path: '/listings/:id',
        pageBuilder: (context, state) => ledgerPage(
          state,
          ListingDetailScreen(listingId: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => ledgerPage(state, const ListingsListScreen()),
      ),
      GoRoute(
        path: '/matches',
        pageBuilder: (context, state) => ledgerPage(state, const MatchesScreen()),
      ),
      GoRoute(
        path: '/claims',
        pageBuilder: (context, state) => ledgerPage(state, const ClaimsScreen()),
      ),
      GoRoute(
        path: '/conversations',
        pageBuilder: (context, state) => ledgerPage(state, const ConversationsScreen()),
      ),
      GoRoute(
        path: '/conversations/:id',
        pageBuilder: (context, state) => ledgerPage(
          state,
          ChatScreen(conversationId: int.parse(state.pathParameters['id']!)),
        ),
      ),
    ],
  );
});
