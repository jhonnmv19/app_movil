// lib/presentation/screens/welcome_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _boilController;

  late Animation<double> _ladleProgressAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _boilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _ladleProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeInOutCubic),
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _boilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.08),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Partículas de fondo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SteamParticlesPainter(_pulseController.value),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 10),

                  // TÍTULO STRICTAMENTE CENTRADO EN PANTALLA
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _ladleProgressAnimation,
                      _boilController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      final progress = _ladleProgressAnimation.value;
                      final boilValue = _boilController.value;
                      final pulseValue = _pulseController.value;

                      // 1. Calculamos el tamaño real que ocupa el texto exactamente
                      final textSpan = TextSpan(
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: const Color(0xFF1A1A1A),
                            ),
                        children: const [
                          TextSpan(text: 'Ruta '),
                          TextSpan(
                            text: 'del Sabor',
                            style: TextStyle(color: AppTheme.primaryOrange),
                          ),
                        ],
                      );

                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      )..layout();

                      final double exactTextWidth = textPainter.width;
                      final double exactTextHeight = textPainter.height;

                      // 2. Trayectoria calculada exclusivamente sobre el ancho del texto centrado
                      final double startX = -exactTextWidth / 2;
                      final double ladleX = startX + (progress * exactTextWidth);
                      final double revealEdgeX = startX + (progress * exactTextWidth);

                      final double boilY = math.sin(boilValue * math.pi * 2) * 4;
                      final double boilAngle = math.cos(boilValue * math.pi) * 0.1;

                      return Center(
                        child: SizedBox(
                          width: exactTextWidth,
                          height: exactTextHeight + 40,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Texto base centrado (Sombra / Invisible)
                              Opacity(
                                opacity: 0.0,
                                child: RichText(text: textSpan),
                              ),

                              // Texto que se va descubriendo
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ClipRect(
                                  clipper: _ExactTextRevealClipper(progress),
                                  child: RichText(text: textSpan),
                                ),
                              ),

                              // Destello luminoso en el borde de servido
                              if (progress > 0.01 && progress < 0.99)
                                Transform.translate(
                                  offset: Offset(revealEdgeX, 0),
                                  child: CustomPaint(
                                    size: const Size(20, 50),
                                    painter: _SparkleGlowPainter(
                                      pulseValue: pulseValue,
                                      boilValue: boilValue,
                                    ),
                                  ),
                                ),

                              // Cucharón sirviendo estrictamente sobre el texto
                              Transform.translate(
                                offset: Offset(ladleX, -28 + boilY),
                                child: Transform.rotate(
                                  angle: -0.3 + boilAngle,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryOrange.withOpacity(0.4),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.soup_kitchen,
                                      size: 44.0,
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Tarjeta Promocional
                  FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: SlideTransition(
                      position: _contentSlideAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Descubre la capital gastronómica de Bolivia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Image.network(
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 220,
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 80,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Explora los platos tradicionales, ferias culinarias y los rincones más icónicos de Cochabamba.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones
                  FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: SlideTransition(
                      position: _contentSlideAnimation,
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryOrange.withOpacity(
                                        0.25 + (_pulseController.value * 0.2),
                                      ),
                                      blurRadius: 12 + (_pulseController.value * 8),
                                      spreadRadius: _pulseController.value * 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.comensalMainNav,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryOrange,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Explorar como Visitante',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: '¿Ya tienes una cuenta? ',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Iniciar Sesión',
                                    style: TextStyle(
                                      color: AppTheme.primaryOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExactTextRevealClipper extends CustomClipper<Rect> {
  final double revealProgress;
  _ExactTextRevealClipper(this.revealProgress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * revealProgress, size.height);
  }

  @override
  bool shouldReclip(covariant _ExactTextRevealClipper oldDelegate) {
    return oldDelegate.revealProgress != revealProgress;
  }
}

class _SparkleGlowPainter extends CustomPainter {
  final double pulseValue;
  final double boilValue;

  _SparkleGlowPainter({required this.pulseValue, required this.boilValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amberAccent.withOpacity(0.8),
          AppTheme.primaryOrange.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 20));

    canvas.drawCircle(center, 14 + (pulseValue * 5), glowPaint);

    final sparkPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final random = math.Random(12);
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (boilValue * math.pi);
      final dist = 6.0 + (random.nextDouble() * 8);
      final sparkX = center.dx + math.cos(angle) * dist;
      final sparkY = center.dy + math.sin(angle) * dist;

      canvas.drawCircle(Offset(sparkX, sparkY), 1.2 + (pulseValue * 1.2), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleGlowPainter oldDelegate) => true;
}

class _SteamParticlesPainter extends CustomPainter {
  final double animationValue;
  _SteamParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryOrange.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final radius = 3.0 + random.nextDouble() * 5.0;
      final currentY = (startY - (animationValue * 50 * (i % 3 + 1))) % size.height;

      canvas.drawCircle(Offset(x, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamParticlesPainter oldDelegate) => true;
}