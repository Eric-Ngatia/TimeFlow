import 'package:flutter/material.dart';

import '../../theme/motion_tokens.dart';

/// Animation d'entrée réutilisable : fondu + léger décalage vertical.
///
/// **Décision de conception volontaire** : animation *one-shot* — l'
/// `AnimationController` est démarré une seule fois (`forward()`, jamais
/// `repeat()`) pour rester compatible avec `tester.pumpAndSettle()`, déjà
/// massivement utilisé dans les tests existants (cf. Risques du plan
/// Phase 5). À la différence du contrôleur pulsant de `CurrentActivityCard`.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.06),
    this.duration = MotionTokens.entrance,
    this.curve = MotionTokens.entranceCurve,
    super.key,
  });

  /// Contenu à faire apparaître.
  final Widget child;

  /// Délai avant le démarrage de l'animation (utilisé pour le stagger).
  final Duration delay;

  /// Décalage de départ (fraction de la taille du widget), qui se résorbe
  /// vers `Offset.zero` au fil de l'animation.
  final Offset offset;

  /// Durée de l'animation (fondu + glissement).
  final Duration duration;

  /// Courbe appliquée à l'animation.
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = curved;
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(curved);

    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
