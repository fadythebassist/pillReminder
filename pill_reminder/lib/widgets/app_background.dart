import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg,
            scheme.primary.withValues(alpha: 0.08),
            bg,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -140,
            child: _GlowBlob(
                color: scheme.secondary.withValues(alpha: 0.18), size: 320),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _GlowBlob(
                color: scheme.primary.withValues(alpha: 0.16), size: 320),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: _GlowBlob(
                color: scheme.tertiary.withValues(alpha: 0.10), size: 200),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
