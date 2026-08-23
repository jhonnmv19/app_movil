// lib/presentation/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _ladleSlideAnimation;
  late Animation<double> _textRevealAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  final String _titlePart1 = 'Ruta ';
  final String _titlePart2 = 'del Sabor';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _ladleSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.6, 0.0),
      end: const Offset(0.6, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 10),

              // Animación del Cucharón y Título
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _textRevealAnimation.value,
                            child: RichText(
                              maxLines: 1,
                              softWrap: false,
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                children: [
                                  TextSpan(text: _titlePart1),
                                  TextSpan(
                                    text: _titlePart2,
                                    style: const TextStyle(
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: SlideTransition(
                          position: _ladleSlideAnimation,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Transform.translate(
                              offset: const Offset(-20, -25),
                              child: Transform.rotate(
                                angle: -0.2,
                                child: const Icon(
                                  Icons.soup_kitchen,
                                  size: 42,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Contenido Promocional
              FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Descubre el sabor de Bolivia',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.restaurant,
                              size: 80,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Explora los mejores platos, ferias y puestos locales en Cochabamba.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Acciones de Entrada (Visitante o Login)
              FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Column(
                    children: [
                      // Botón Entrar como Visitante
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.mainNav,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(height: 12),
                      
                      // Enlace a Iniciar Sesión
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
    );
  }
}