import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/session_service.dart';
import '../../../data/models/usuario_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final emailIngresado = _emailController.text.trim().toLowerCase();
      final passwordIngresada = _passwordController.text;

      // 1. Consultar directamente en usuarios_r_sabor
      final response = await supabase
          .from('usuarios_r_sabor')
          .select()
          .eq('email', emailIngresado)
          .maybeSingle();

      if (!mounted) return;

      // Imprimir respuesta en consola para depuración
      debugPrint('--> RESPUESTA SUPABASE USUARIO: $response');

      if (response == null) {
        _mostrarSnackBar('El correo electrónico no está registrado', Colors.redAccent);
        return;
      }

      // 2. Verificar Contraseña
      final String passwordEnBD = response['password_hash']?.toString() ?? '';
      if (passwordEnBD != passwordIngresada) {
        _mostrarSnackBar('Contraseña incorrecta. Verifica tus credenciales.', Colors.redAccent);
        return;
      }

      // 3. Validar Estado de la Cuenta
      final String rawEstado = response['estado']?.toString().toLowerCase() ?? 'activo';
      if (rawEstado == 'bloqueado' || rawEstado == 'inactivo') {
        _mostrarSnackBar('Tu cuenta está actualmente $rawEstado.', Colors.redAccent);
        return;
      }

      // 4. Mapear datos e Iniciar Sesión en Singleton
      final usuarioMap = Map<String, dynamic>.from(response);
      final usuarioActual = UsuarioModel.fromJson(usuarioMap);
      SessionService().iniciarSesion(usuarioActual);

      // 5. Redirección según Rol
      final String rol = response['rol']?.toString().toLowerCase() ?? 'comensal';
      debugPrint('--> ROL DETECTADO: $rol');

      switch (rol) {
        case 'admin':
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case 'dueno':
        case 'dueño':
        case 'duenno':
          Navigator.pushReplacementNamed(context, AppRoutes.duennoMainNav);
          break;
        case 'comensal':
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.comensalMainNav);
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('--> ERROR EN LOGIN: $e');
      debugPrint('--> STACKTRACE: $stackTrace');
      if (!mounted) return;
      _mostrarSnackBar('Error inesperado al iniciar sesión: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: colorFondo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo e Icono
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
                  Text(
                    'Ingresa para explorar los menús del día',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      final emailRegExp =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(val.trim())) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón Iniciar Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD64E28),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Ingresar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Enlace a Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes una cuenta? ',
                          style: theme.textTheme.bodySmall),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}