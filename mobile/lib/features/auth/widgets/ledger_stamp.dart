import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/motion.dart';

/// Signature detail: a registry stamp thumps down onto the page — scale
/// overshoot, a slight rotation settle, and a synced haptic — on successful
/// register/login, before the app hands off to Home.
class LedgerStamp extends StatefulWidget {
  const LedgerStamp({super.key, required this.onComplete, this.label = 'VÉRIFIÉ'});

  final VoidCallback onComplete;
  final String label;

  @override
  State<LedgerStamp> createState() => _LedgerStampState();
}

class _LedgerStampState extends State<LedgerStamp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: LedgerMotion.stamp);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 2.4, end: 0.92).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 30),
    ]).animate(_controller);

    _rotation = Tween<double>(begin: -0.35, end: -0.1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.25, curve: Curves.easeIn));

    Future.delayed(
      Duration(milliseconds: (LedgerMotion.stamp.inMilliseconds * 0.55).round()),
      () {
        if (mounted) HapticFeedback.mediumImpact();
      },
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), widget.onComplete);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value.clamp(0, 1),
        child: Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
      ),
      child: Container(
        width: 148,
        height: 148,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.primary, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: scheme.primary, size: 36),
            const SizedBox(height: 4),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the stamp full-screen over a translucent parchment scrim and
/// resolves once its animation (and settle delay) has finished.
Future<void> showLedgerStamp(BuildContext context, {String label = 'VÉRIFIÉ'}) {
  final completer = Completer<void>();
  final scheme = Theme.of(context).colorScheme;

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: scheme.surfaceContainerLowest.withValues(alpha: 0.92),
    transitionDuration: LedgerMotion.quick,
    pageBuilder: (dialogContext, _, _) => Center(
      child: LedgerStamp(
        label: label,
        onComplete: () => Navigator.of(dialogContext).pop(),
      ),
    ),
  ).then((_) => completer.complete());

  return completer.future;
}
