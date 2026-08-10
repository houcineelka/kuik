import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/motion.dart';

/// Signature page transition: a gentle horizontal drift with a fade,
/// evoking a page turning in a ledger rather than a mechanical slide.
CustomTransitionPage<void> ledgerPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: LedgerMotion.deliberate,
    reverseTransitionDuration: LedgerMotion.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
          .chain(CurveTween(curve: LedgerMotion.transition))
          .animate(animation);
      final fade = CurvedAnimation(parent: animation, curve: LedgerMotion.transition);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
