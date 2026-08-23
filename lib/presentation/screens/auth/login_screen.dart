import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final data = await supabase
          .from('usuarios_r_sabor')
          .select()
          .eq('email', email)
          .eq('password_hash', password)
          .maybeSingle();

      if (!mounted) return;

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas o usuario no encontrado'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        final estado = data['estado'] as String?;
        final rol = data['rol'] as String?;

        if (estado == 'bloqueado' || estado == 'inactivo') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tu cuenta está actualmente $estado.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Redirección por rol
        if (rol == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 48,
                    color: Color(0xFFD64E28),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'La Ruta del Sabor',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD64E28),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Bienvenido de nuevo', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Ingresa para explorar los menús del día', style: theme.textTheme.bodySmall),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD64E28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes una cuenta? ', style: theme.textTheme.bodySmall),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: Text(
                        'Regístrate',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD64E28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Acceso para Administradores
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                  icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF1E293B)),
                  label: const Text(
                    'Acceso a Panel de Administración',
                    style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}