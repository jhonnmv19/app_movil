import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../core/routes/app_routes.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _codigoAdminController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codigoAdminController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAdmin() async {
    final codigo = _codigoAdminController.text.trim();
    final password = _passwordController.text.trim();

    if (codigo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Consultar administrador con los datos del usuario relacionado
      final adminData = await supabase
          .from('administradores_r_sabor')
          .select('*, usuarios_r_sabor!inner(*)')
          .eq('codigo_admin', codigo)
          .maybeSingle();

      if (adminData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de administrador no registrado')),
          );
        }
        return;
      }

      final usuario = adminData['usuarios_r_sabor'];
      final storedHash = usuario['password_hash'] as String?;
      final rol = usuario['rol'] as String?;
      final estado = usuario['estado'] as String?;

      if (estado != 'activo') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La cuenta de usuario se encuentra inactiva o bloqueada')),
          );
        }
        return;
      }

      if (rol != 'admin') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El usuario asignado no posee el rol de administrador')),
          );
        }
        return;
      }

      // 2. Verificar contraseña hash
      bool isValidPassword = false;
      if (storedHash != null && storedHash.isNotEmpty) {
        try {
          // Intentar verificar con Bcrypt
          isValidPassword = BCrypt.checkpw(password, storedHash);
        } catch (_) {
          // En caso de que se haya insertado en texto plano en la BD
          isValidPassword = (storedHash == password);
        }
      }

      if (isValidPassword) {
        // Actualizar último ingreso
        await supabase
            .from('administradores_r_sabor')
            .update({'ultimo_ingreso': DateTime.now().toIso8601String()})
            .eq('id', adminData['id']);

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña de administrador incorrecta')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error en login admin: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de autenticación: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Acceso Administrativo'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 64, color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'Iniciar Sesión como Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codigoAdminController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Administrador (ej. ADM-001-SUP)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('INGRESAR AL PANEL', style: TextStyle(fontSize: 16)),
                    ),
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