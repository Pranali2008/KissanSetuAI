import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Which small animation each service icon plays.
enum ServiceFx { sprout, scan, bounce, sun, drop, float }

/// Compact card: coloured round badge with an animated icon + label.
/// Pressing the card gives a small "squeeze" animation.
class ServiceTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final ServiceFx fx;
  final List<Color> colors;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.label,
    required this.icon,
    required this.fx,
    required this.colors,
    required this.onTap,
  });

  @override
  State<ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<ServiceTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // The animated picture inside the badge.
  Widget _icon(double v) {
    final s = math.sin(v * 2 * math.pi);
    switch (widget.fx) {
      case ServiceFx.sprout: // crop advice: plant grows and sways
        return Transform.rotate(
          angle: s * 0.12,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: 1 + 0.10 * s,
            alignment: Alignment.bottomCenter,
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
        );

      case ServiceFx.scan: // disease scan: magnifier circles over a leaf
        {
          final a = v * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.eco_rounded,
                  color: Colors.white.withAlpha(235), size: 26),
              Transform.translate(
                offset: Offset(math.cos(a) * 6, math.sin(a) * 6),
                child: const Icon(Icons.search_rounded,
                    color: Color(0xFFFFF59D), size: 19),
              ),
            ],
          );
        }

      case ServiceFx.bounce: // market price: rupee symbol bounces
        {
          final b = math.sin(v * 4 * math.pi).abs();
          return Transform.translate(
            offset: Offset(0, -6 * b),
            child: Transform.scale(
              scale: 1 + 0.08 * b,
              child: const Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          );
        }

      case ServiceFx.sun: // weather: sun rotates, cloud drifts
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-3, -4),
              child: Transform.rotate(
                angle: v * 2 * math.pi,
                child: const Icon(Icons.wb_sunny_rounded,
                    color: Color(0xFFFFEB3B), size: 27),
              ),
            ),
            Transform.translate(
              offset: Offset(5 + s * 3, 6),
              child: const Icon(Icons.cloud_rounded,
                  color: Colors.white, size: 23),
            ),
          ],
        );

      case ServiceFx.drop: // soil health: a water drop falls onto the soil
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: const Offset(0, 4),
              child: Transform.scale(
                scale: 1 + 0.06 * s,
                child: Icon(widget.icon, color: Colors.white, size: 27),
              ),
            ),
            Positioned(
              top: -8 + v * 13,
              child: Opacity(
                opacity: (1 - v).clamp(0.0, 1.0).toDouble(),
                child: const Icon(Icons.water_drop_rounded,
                    color: Color(0xFF81D4FA), size: 13),
              ),
            ),
          ],
        );

      case ServiceFx.float: // schemes: building floats gently
        return Transform.translate(
          offset: Offset(0, s * 3),
          child: Icon(widget.icon, color: Colors.white, size: 27),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glow = widget.colors.last;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: alpha(cs.surface, 0.97),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: alpha(glow, 0.30)),
            boxShadow: [
              BoxShadow(
                color: alpha(glow, 0.16),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: alpha(glow, 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) => _icon(_c.value),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}