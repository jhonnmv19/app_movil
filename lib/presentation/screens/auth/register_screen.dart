import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de usuario
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Controladores de negocio (si se registra como dueño)
  final _nombreNegocioController = TextEditingController();
  final _direccionNegocioController = TextEditingController();
  final _descripcionNegocioController = TextEditingController();

  String _rolSeleccionado = 'comensal'; // Por defecto: comensal/visitante
  String? _documentoPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _nombreNegocioController.dispose();
    _direccionNegocioController.dispose();
    _descripcionNegocioController.dispose();
    super.dispose();
  }

  void _seleccionarDocumento() {
    setState(() {
      _documentoPath = 'ci_nit_adjunto.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documento adjuntado correctamente'),
        backgroundColor: Color(0xFFD64E28),
      ),
    );
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rolSeleccionado == 'dueño' && _documentoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adjunta tu documento de identidad (CI / NIT) para solicitar el alta de negocio.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Registro en la tabla usuarios_r_sabor
      final userResponse = await supabase
          .from('usuarios_r_sabor')
          .insert({
            'nombre_completo': _nombreController.text.trim(),
            'email': _emailController.text.trim(),
            'password_hash': _passwordController.text, // Recomienda usar Auth nativo de Supabase
            'telefono': _telefonoController.text.trim(),
            'rol': _rolSeleccionado,
            'estado': 'activo',
          })
          .select('id')
          .single();

      final BigInt usuarioId = BigInt.parse(userResponse['id'].toString());

      // 2. Si se registra como Dueño, creamos la solicitud en solicitudes_registro_r_sabor
      if (_rolSeleccionado == 'dueño') {
        await supabase.from('solicitudes_registro_r_sabor').insert({
          'usuario_id': usuarioId.toInt(),
          'nombre_negocio_propuesto': _nombreNegocioController.text.trim(),
          'descripcion_negocio': _descripcionNegocioController.text.trim(),
          'direccion_propuesta': _direccionNegocioController.text.trim(),
          'telefono_contacto': _telefonoController.text.trim(),
          'documento_identidad_url': _documentoPath,
          'estado_solicitud': 'pendiente',
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _rolSeleccionado == 'dueño'
                ? 'Registro completado. Tu solicitud de negocio está pendiente de revisión.'
                : '¡Bienvenido a La Ruta del Sabor!',
          ),
          backgroundColor: const Color(0xFFD64E28),
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrarse: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 40,
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

                // Selector de Rol (Comensal / Dueño)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD64E28).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Color(0xFFD64E28)),
                      const SizedBox(width: 12),
                      const Text('Quiero registrarme como:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _rolSeleccionado,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'comensal', child: Text('Visitante / Comensal')),
                          DropdownMenuItem(value: 'dueño', child: Text('Dueño de Negocio')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _rolSeleccionado = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Datos de la Persona
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu correo' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu teléfono' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),

                // Si selecciona 'dueño', desplegar formulario adicional de negocio
                if (_rolSeleccionado == 'dueño') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Datos de Postulación de Negocio',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD64E28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombreNegocioController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del negocio o puesto',
                      prefixIcon: const Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre del negocio' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _direccionNegocioController,
                    decoration: InputDecoration(
                      labelText: 'Dirección o ubicación',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionNegocioController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Descripción del negocio',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _seleccionarDocumento,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2EE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD64E28).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_outlined, color: Color(0xFFD64E28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _documentoPath ?? 'Adjuntar Documento (CI / NIT)',
                              style: TextStyle(
                                color: _documentoPath != null ? Colors.black87 : Colors.black54,
                                fontWeight: _documentoPath != null ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            _documentoPath != null ? Icons.check_circle : Icons.upload_file_rounded,
                            color: const Color(0xFFD64E28),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD64E28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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