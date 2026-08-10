import 'package:flutter/animation.dart';

/// Warm and deliberate, not snappy or bouncy — motion that feels like
/// carefully turning a page in a ledger, never a mechanical snap.
class LedgerMotion {
  LedgerMotion._();

  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 350);
  static const Duration deliberate = Duration(milliseconds: 450);
  static const Duration stamp = Duration(milliseconds: 550);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve transition = Curves.easeInOutCubic;
}
