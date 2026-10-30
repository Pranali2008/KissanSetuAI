import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Clean off-white page with a faint pencil-sketch banyan tree and farm
/// furrows (like the KissanAI website hero). It is "alive":
///  - branches and leaves sway in the wind
///  - aerial roots swing gently
///  - grass on the horizon waves
///  - wind lines and leaves drift across the screen
///  - the tree moves slower than the content when you scroll (depth / parallax)
///
/// Usage: FarmerBackground(scroll: offsetNotifier, child: YourContent())
class FarmerBackground extends StatefulWidget {
  final Widget child;
  final ValueListenable<double>? scroll;
  const FarmerBackground({super.key, required this.child, this.scroll});

  @override
  State<FarmerBackground> createState() => _FarmerBackgroundState();
}

class _FarmerBackgroundState extends State<FarmerBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();
  final ValueNotifier<double> _zero = ValueNotifier<double>(0);

  @override
  void dispose() {
    _c.dispose();
    _zero.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ValueListenable<double> scroll = widget.scroll ?? _zero;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_c, scroll]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _SketchPainter(
                    _c.value,
                    dark,
                    scroll.value.clamp(0.0, 600.0).toDouble(),
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _SketchPainter extends CustomPainter {
  final double t; // 0..1, loops every 20 s
  final bool dark;
  final double scroll;
  _SketchPainter(this.t, this.dark, this.scroll);

  late double w, h, groundY;
  int _n = 0;

  final Path _pOutline = Path();
  final Path _pHatch = Path();
  final Path _pLeaf = Path();
  final Path _pRoot = Path();
  final Path _pFly = Path();

  Color get _inkColor =>
      dark ? const Color(0xFFC3D3C0) : const Color(0xFF4F5B49);

  double _sin(double speed, double phase) =>
      math.sin(t * 2 * math.pi * speed + phase);

  /// Stable pseudo random number 0..1 (same every frame => no flicker).
  double _rand(double x) {
    final v = math.sin(x * 12.9898) * 43758.5453;
    return v - v.floorToDouble();
  }

  double _next() => _rand((_n++) * 3.7 + 1.0);

  Paint _stroke(double width, int a) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = _inkColor.withAlpha(a);

  @override
  void paint(Canvas canvas, Size size) {
    w = size.width;
    h = size.height;
    groundY = h * 0.52;
    _n = 0;

    _background(canvas, size);

    // farm furrows (slow parallax)
    canvas.save();
    canvas.translate(0, -scroll * 0.12);
    _field(canvas);
    canvas.restore();

    // sketch tree (a bit faster parallax)
    canvas.save();
    canvas.translate(0, -scroll * 0.30);
    _shade(canvas);
    _buildTree();
    _paintTree(canvas);
    canvas.restore();

    _windAndLeaves(canvas);
  }

  // ----------------------------------------------------------- background
  void _background(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF0B120E), Color(0xFF111A15)]
              : const [Color(0xFFFFFFFF), Color(0xFFF1F5EE)],
        ).createShader(rect),
    );
  }

  /// Soft grey-green "shade" behind the canopy, like a pencil smudge.
  void _shade(Canvas c) {
    final center = Offset(w * 0.42, groundY - h * 0.27);
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(1.0, 0.62);
    c.drawCircle(
      Offset.zero,
      w * 0.62,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _inkColor.withAlpha(dark ? 24 : 22),
            _inkColor.withAlpha(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: w * 0.62)),
    );
    c.restore();
  }

  // ---------------------------------------------------------------- field
  void _field(Canvas c) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _inkColor.withAlpha(dark ? 16 : 22);
    final vp = Offset(w * 0.62, groundY);
    final bottom = h + 400;

    for (int i = -8; i <= 8; i++) {
      c.drawLine(vp, Offset(w * 0.5 + i * w * 0.22, bottom), p);
    }
    for (int k = 1; k <= 14; k++) {
      final y = groundY + (bottom - groundY) * math.pow(k / 14, 1.8).toDouble();
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 24) {
        path.lineTo(x, y + math.sin(x * 0.02 + k) * 2);
      }
      c.drawPath(path, p);
    }

    // waving grass / crop tufts along the horizon
    final grass = Path();
    for (double x = 0; x <= w; x += 7) {
      final r = _rand(x * 1.7);
      final hh = 7 + r * 11;
      final lean = _sin(2, x * 0.03) * 3.5 + 1.5;
      grass.moveTo(x, groundY);
      grass.quadraticBezierTo(
          x + lean * 0.3, groundY - hh * 0.6, x + lean, groundY - hh);
    }
    c.drawPath(grass, _stroke(1, dark ? 44 : 56));
  }

  // ----------------------------------------------------------------- tree
  Offset _quad(Offset a, Offset b, Offset c, double f) {
    final m = 1 - f;
    return a * (m * m) + b * (2 * m * f) + c * (f * f);
  }

  void _buildTree() {
    final base = Offset(w * 0.09, groundY);

    // big banyan trunks + one wide horizontal limb
    _limb(base + Offset(-w * 0.05, 0), -0.28, h * 0.15, w * 0.085, 5, 0.0);
    _limb(base, 0.04, h * 0.17, w * 0.10, 5, 1.7);
    _limb(base + Offset(w * 0.05, 0), 0.38, h * 0.15, w * 0.085, 5, 3.1);
    _limb(Offset(base.dx + w * 0.04, groundY - h * 0.14), 1.05, h * 0.20,
        w * 0.05, 4, 4.4);

    // root flares at the bottom of the trunk
    for (int i = -3; i <= 3; i++) {
      _pOutline.moveTo(base.dx + i * w * 0.025, base.dy - h * 0.03);
      _pOutline.quadraticBezierTo(base.dx + i * w * 0.035, base.dy - h * 0.005,
          base.dx + i * w * 0.06, base.dy + h * 0.008);
    }

    // pencil shading on the ground around the trunk
    for (int k = 0; k < 40; k++) {
      final x = base.dx - w * 0.1 + _rand(k * 2.1) * w * 0.5;
      final y = groundY + _rand(k * 3.3 + 1) * h * 0.03;
      final len = 10 + _rand(k * 4.7) * 12;
      _pHatch.moveTo(x, y);
      _pHatch.lineTo(x + len, y + 1.5);
    }
  }

  /// One tapered limb drawn as pencil lines. Deeper limbs sway more.
  void _limb(Offset p, double ang, double len, double wd, int depth,
      double phase) {
    final r1 = _next();
    final r2 = _next();
    final r3 = _next();

    final amp = (6 - depth).toDouble();
    final sway = _sin(2, phase + depth * 0.5) * 0.006 * amp +
        _sin(5, phase * 2 + depth) * 0.0025 * amp;
    final a = ang + sway;

    final d = Offset(math.sin(a), -math.cos(a)); // direction
    final n = Offset(math.cos(a), math.sin(a)); // normal
    final bend = (r1 - 0.5) * len * 0.18;
    final e = p + d * len + n * (bend * 0.4);
    final c = (p + e) / 2 + n * bend;

    final w0 = wd, w1 = wd * 0.72, wm = (w0 + w1) / 2;

    // outline (two edges)
    _pOutline.moveTo(p.dx - n.dx * w0 / 2, p.dy - n.dy * w0 / 2);
    _pOutline.quadraticBezierTo(c.dx - n.dx * wm / 2, c.dy - n.dy * wm / 2,
        e.dx - n.dx * w1 / 2, e.dy - n.dy * w1 / 2);
    _pOutline.moveTo(p.dx + n.dx * w0 / 2, p.dy + n.dy * w0 / 2);
    _pOutline.quadraticBezierTo(c.dx + n.dx * wm / 2, c.dy + n.dy * wm / 2,
        e.dx + n.dx * w1 / 2, e.dy + n.dy * w1 / 2);

    // bark lines running along the limb
    final lines = (wd / 4.5).floor().clamp(0, 6);
    for (int j = 1; j <= lines; j++) {
      final f = j / (lines + 1) - 0.5;
      final jit = (_next() - 0.5) * 1.2;
      _pHatch.moveTo(p.dx + n.dx * w0 * f, p.dy + n.dy * w0 * f);
      _pHatch.quadraticBezierTo(
          c.dx + n.dx * (wm * f + jit),
          c.dy + n.dy * (wm * f + jit),
          e.dx + n.dx * w1 * f,
          e.dy + n.dy * w1 * f);
    }

    // short shading ticks on the shadow side
    if (depth >= 3) {
      final cnt = (len / 8).floor();
      for (int m = 1; m < cnt; m++) {
        final f = m / cnt;
        final pos = _quad(p, c, e, f);
        final wf = w0 + (w1 - w0) * f;
        final s = pos + n * (wf * 0.5);
        final end = s - n * (wf * (0.25 + 0.25 * _next())) + d * 2.5;
        _pHatch.moveTo(s.dx, s.dy);
        _pHatch.lineTo(end.dx, end.dy);
      }
    }

    // hanging aerial roots (banyan style)
    if ((depth == 3 || depth == 4) && r2 < 0.45) {
      final rx = e.dx + (r3 - 0.5) * 18;
      final sw = _sin(2, phase + 1.0) * 4;
      for (int s = -1; s <= 1; s++) {
        final off = s * 2.4;
        _pRoot.moveTo(e.dx + off, e.dy);
        _pRoot.quadraticBezierTo(e.dx + off + sw + (rx - e.dx) * 0.3,
            (e.dy + groundY) / 2, rx + off, groundY);
      }
    }

    // leaves at the tips
    if (depth == 1) {
      for (int i = 0; i < 7; i++) {
        final la = _next() * 2 * math.pi;
        final dist = _next() * 14;
        final lp = e + Offset(math.cos(la), math.sin(la)) * dist;
        final dir = la + _sin(3, phase + i) * 0.3;
        final ll = 8 + _next() * 7;
        _leafInto(_pLeaf, lp, dir, ll);
      }
      return;
    }

    // child limbs
    final kids = depth == 3 ? 3 : 2;
    for (int i = 0; i < kids; i++) {
      final side = kids == 3 ? (i - 1.0) : (i == 0 ? -1.0 : 1.0);
      final spread = 0.38 + 0.30 * _next();
      final childAng = (a + side * spread + 0.04).clamp(-1.45, 1.45).toDouble();
      _limb(e, childAng, len * (0.76 + 0.08 * _next()), wd * 0.66, depth - 1,
          phase + i * 1.3 + depth);
    }
  }

  void _leafInto(Path path, Offset p, double ang, double len) {
    final d = Offset(math.cos(ang), math.sin(ang));
    final n = Offset(-d.dy, d.dx);
    final tip = p + d * len;
    final mid = p + d * (len * 0.5);
    final b = len * 0.28;
    path.moveTo(p.dx, p.dy);
    path.quadraticBezierTo(
        mid.dx + n.dx * b, mid.dy + n.dy * b, tip.dx, tip.dy);
    path.quadraticBezierTo(mid.dx - n.dx * b, mid.dy - n.dy * b, p.dx, p.dy);
    path.moveTo(p.dx, p.dy);
    path.lineTo(p.dx + d.dx * len * 0.8, p.dy + d.dy * len * 0.8);
  }

  void _paintTree(Canvas canvas) {
    canvas.drawPath(_pOutline, _stroke(1.1, dark ? 72 : 90));
    canvas.save();
    canvas.translate(0.7, 0.5); // second pass = hand-drawn doubled line
    canvas.drawPath(_pOutline, _stroke(0.7, dark ? 40 : 50));
    canvas.restore();
    canvas.drawPath(_pHatch, _stroke(0.7, dark ? 38 : 48));
    canvas.drawPath(_pRoot, _stroke(0.9, dark ? 52 : 66));
    canvas.drawPath(_pLeaf, _stroke(0.8, dark ? 50 : 62));
  }

  // ------------------------------------------------------- wind + leaves
  void _windAndLeaves(Canvas c) {
    c.save();
    c.translate(0, -scroll * 0.2);

    // wind swirls drifting to the right (whole number => seamless loop)
    final wind = _stroke(1, dark ? 30 : 40);
    for (int i = 0; i < 5; i++) {
      final sp = (i % 2 == 0) ? 1.0 : 2.0;
      final len = 110.0 + i * 18;
      final x = ((i * 0.21 + t * sp) % 1.0) * (w + len + 120) - len - 60;
      final y = h * (0.11 + i * 0.065) + _sin(2, i.toDouble()) * 5;
      final path = Path()
        ..moveTo(x, y)
        ..cubicTo(x + len * 0.3, y - 8, x + len * 0.65, y + 8, x + len, y)
        ..cubicTo(x + len + 14, y - 3, x + len + 16, y - 16, x + len + 4, y - 14);
      c.drawPath(path, wind);
    }

    // sketched leaves blowing across
    for (int i = 0; i < 7; i++) {
      final sp = (i % 3 == 0) ? 2.0 : 1.0;
      final x = ((_rand(i * 2.3) + t * sp) % 1.0) * (w + 60) - 30;
      final y = h * (0.10 + 0.38 * _rand(i * 5.1 + 1)) +
          _sin(3, i.toDouble()) * 14;
      _leafInto(_pFly, Offset(x, y), t * 2 * math.pi * 2 + i,
          9 + _rand(i * 1.9) * 5);
    }
    c.drawPath(_pFly, _stroke(0.9, dark ? 60 : 78));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _SketchPainter old) =>
      old.t != t || old.dark != dark || old.scroll != scroll;
}