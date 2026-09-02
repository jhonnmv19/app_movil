import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/session_service.dart';
import '../../../data/models/usuario_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores Usuario
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Controladores Negocio
  final _nombreNegocioController = TextEditingController();
  final _direccionNegocioController = TextEditingController();
  final _descripcionNegocioController = TextEditingController();

  // Variables GPS
  double? _latitudSeleccionada;
  double? _longitudSeleccionada;
  bool _obteniendoUbicacion = false;

  // Rol predeterminado (Coincide con CHECK de BD)
  String _rolSeleccionado = 'comensal';

  // Archivos locales (Usamos PlatformFile para compatibilidad Web y Móvil)
  PlatformFile? _archivoDocumento;
  PlatformFile? _archivoFotoLocal;
  String? _nombreDocSeleccionado;
  String? _nombreFotoSeleccionada;

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

  // Captura segura de posición GPS
  Future<void> _obtenerUbicacionGPS() async {
    setState(() => _obteniendoUbicacion = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _mostrarSnackBar('El GPS está desactivado. Por favor, actívalo.', Colors.deepOrange);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _mostrarSnackBar('Permisos de ubicación denegados.', Colors.redAccent);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _mostrarSnackBar('Los permisos de ubicación están denegados permanentemente.', Colors.redAccent);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (!mounted) return;
      setState(() {
        _latitudSeleccionada = position.latitude;
        _longitudSeleccionada = position.longitude;
      });

      _mostrarSnackBar('Ubicación capturada exitosamente.', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar('Error al obtener ubicación: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _obteniendoUbicacion = false);
    }
  }

  // Selección de documento (Soporta Web gracias a withData: true)
  Future<void> _seleccionarDocumento() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _archivoDocumento = file;
        _nombreDocSeleccionado = file.name;
      });
    }
  }

  // Selección de foto (Soporta Web gracias a withData: true)
  Future<void> _seleccionarFotoLocal() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _archivoFotoLocal = file;
        _nombreFotoSeleccionada = file.name;
      });
    }
  }

  // Subida universal de archivos usando bytes (Compatible con Web y Móvil)
  Future<String?> _subirArchivoASupabase({
    required PlatformFile archivo,
    required String bucketName,
    required String rutaDestino,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      if (archivo.bytes == null) {
        debugPrint('--> ERROR: Los bytes del archivo están vacíos.');
        return null;
      }

      await supabase.storage.from(bucketName).uploadBinary(
            rutaDestino,
            archivo.bytes!,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _obtenerContentType(archivo.extension),
            ),
          );

      return supabase.storage.from(bucketName).getPublicUrl(rutaDestino);
    } catch (e) {
      debugPrint('--> ERROR AL SUBIR ARCHIVO A SUPABASE STORAGE: $e');
      return null;
    }
  }

  String _obtenerContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Registro principal atómico
  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rolSeleccionado == 'dueno') {
      if (_archivoDocumento == null) {
        _mostrarSnackBar('Adjunta tu documento de identidad (CI / NIT).', Colors.redAccent);
        return;
      }
      if (_archivoFotoLocal == null) {
        _mostrarSnackBar('Adjunta una foto de la fachada de tu local.', Colors.redAccent);
        return;
      }
      if (_latitudSeleccionada == null || _longitudSeleccionada == null) {
        _mostrarSnackBar('Obtén la ubicación GPS de tu establecimiento.', Colors.redAccent);
        return;
      }
    }

    setState(() => _isLoading = true);
    int? usuarioIdCreado;

    try {
      final supabase = Supabase.instance.client;
      final emailClean = _emailController.text.trim().toLowerCase();

      // 1. Inserción del Usuario
      final userResponse = await supabase
          .from('usuarios_r_sabor')
          .insert({
            'nombre_completo': _nombreController.text.trim(),
            'email': emailClean,
            'password_hash': _passwordController.text,
            'telefono': _telefonoController.text.trim(),
            'rol': _rolSeleccionado,
            'estado': 'activo',
          })
          .select()
          .single();

      final usuarioCreado = UsuarioModel.fromJson(Map<String, dynamic>.from(userResponse));
      usuarioIdCreado = usuarioCreado.id;

      // 2. Procesamiento de Solicitud de Negocio para Dueño
      if (_rolSeleccionado == 'dueno') {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extDoc = _archivoDocumento!.extension ?? 'pdf';
        final extFoto = _archivoFotoLocal!.extension ?? 'jpg';

        final pathDoc = 'documentos/ci_nit_${usuarioIdCreado}_$timestamp.$extDoc';
        final docUrl = await _subirArchivoASupabase(
          archivo: _archivoDocumento!,
          bucketName: 'solicitudes_documentos',
          rutaDestino: pathDoc,
        );

        final pathFoto = 'locales/foto_${usuarioIdCreado}_$timestamp.$extFoto';
        final fotoUrl = await _subirArchivoASupabase(
          archivo: _archivoFotoLocal!,
          bucketName: 'solicitudes_documentos',
          rutaDestino: pathFoto,
        );

        if (docUrl == null || fotoUrl == null) {
          throw Exception('No se pudieron subir los archivos adjuntos. Inténtalo de nuevo.');
        }

        await supabase.from('solicitudes_registro_r_sabor').insert({
  'usuario_id': usuarioIdCreado,
  'nombre_negocio_propuesto': _nombreNegocioController.text.trim(),
  'descripcion_negocio': _descripcionNegocioController.text.trim(),
  'direccion_propuesta': _direccionNegocioController.text.trim(),
  'telefono_contacto': _telefonoController.text.trim(),
  'documento_identidad_url': docUrl,
  'estado_solicitud': 'pendiente',
});
      }

      if (!mounted) return;

      // 3. Inicio de Sesión Local
      SessionService().iniciarSesion(usuarioCreado);

      _mostrarSnackBar(
        _rolSeleccionado == 'dueno'
            ? 'Registro completado. Tu solicitud de negocio está pendiente de revisión por el administrador.'
            : '¡Bienvenido a La Ruta del Sabor!',
        const Color(0xFFD64E28),
      );

      // 4. Redirección por Rol
      if (_rolSeleccionado == 'dueno') {
        Navigator.pushReplacementNamed(context, AppRoutes.duennoMainNav);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.comensalMainNav);
      }
    } catch (e) {
      // Rollback manual en caso de fallo durante el proceso del dueño
      if (usuarioIdCreado != null) {
        try {
          final supabase = Supabase.instance.client;
          await supabase.from('usuarios_r_sabor').delete().eq('id', usuarioIdCreado);
        } catch (_) {}
      }

      if (!mounted) return;
      _mostrarSnackBar('Error en el registro: ${e.toString()}', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    if (!mounted) return;
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
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD64E28),
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de Rol
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD64E28).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Color(0xFFD64E28)),
                      const SizedBox(width: 8),
                      const Text('Tipo de usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _rolSeleccionado,
                          items: const [
                            DropdownMenuItem(value: 'comensal', child: Text('Visitante / Comensal')),
                            DropdownMenuItem(value: 'dueno', child: Text('Dueño de Negocio')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _rolSeleccionado = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campos del Usuario
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu nombre completo';
                    if (val.trim().length < 3) return 'El nombre debe tener al menos 3 letras';
                    return null;
                  },
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegExp.hasMatch(val.trim())) return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono / WhatsApp',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu teléfono';
                    if (!RegExp(r'^[0-9]{7,12}$').hasMatch(val.trim())) {
                      return 'Teléfono inválido (7-12 dígitos)';
                    }
                    return null;
                  },
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
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
                    if (val.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),

                // Formulario Condicional para Dueño
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Datos del Establecimiento',
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
                        validator: (val) {
                          if (_rolSeleccionado == 'dueno' && (val == null || val.trim().isEmpty)) {
                            return 'Ingresa el nombre de tu negocio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _direccionNegocioController,
                        decoration: InputDecoration(
                          labelText: 'Dirección o referencia visual',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) {
                          if (_rolSeleccionado == 'dueno' && (val == null || val.trim().isEmpty)) {
                            return 'Ingresa la dirección';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Botón GPS
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2EE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD64E28).withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.my_location_rounded, color: Color(0xFFD64E28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _latitudSeleccionada != null
                                        ? 'Lat: ${_latitudSeleccionada!.toStringAsFixed(5)}, Long: ${_longitudSeleccionada!.toStringAsFixed(5)}'
                                        : 'Ubicación GPS no capturada',
                                    style: TextStyle(
                                      fontWeight: _latitudSeleccionada != null ? FontWeight.bold : FontWeight.normal,
                                      color: _latitudSeleccionada != null ? Colors.black87 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _obteniendoUbicacion ? null : _obtenerUbicacionGPS,
                                icon: _obteniendoUbicacion
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.gps_fixed),
                                label: Text(_obteniendoUbicacion ? 'Obteniendo GPS...' : 'Capturar ubicación GPS'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD64E28),
                                  side: const BorderSide(color: Color(0xFFD64E28)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descripcionNegocioController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción del menú / especialidades',
                          prefixIcon: const Icon(Icons.description_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Adjunto Documento
                      InkWell(
                        onTap: _seleccionarDocumento,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2EE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD64E28).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.file_present_outlined, color: Color(0xFFD64E28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _nombreDocSeleccionado ?? 'Adjuntar CI / NIT (PDF o Imagen)',
                                  style: TextStyle(
                                    color: _nombreDocSeleccionado != null ? Colors.black87 : Colors.black54,
                                    fontWeight: _nombreDocSeleccionado != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                _nombreDocSeleccionado != null ? Icons.check_circle : Icons.upload_file_rounded,
                                color: const Color(0xFFD64E28),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Adjunto Foto
                      InkWell(
                        onTap: _seleccionarFotoLocal,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2EE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD64E28).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add_a_photo_outlined, color: Color(0xFFD64E28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _nombreFotoSeleccionada ?? 'Adjuntar Foto del Local',
                                  style: TextStyle(
                                    color: _nombreFotoSeleccionada != null ? Colors.black87 : Colors.black54,
                                    fontWeight: _nombreFotoSeleccionada != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                _nombreFotoSeleccionada != null ? Icons.check_circle : Icons.upload_file_rounded,
                                color: const Color(0xFFD64E28),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: _rolSeleccionado == 'dueno'
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

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
                        : const Text(
                            'Registrarse e Iniciar Sesión',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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