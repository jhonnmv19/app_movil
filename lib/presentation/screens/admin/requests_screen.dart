import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos de la tabla solicitudes_registro
  final _nombreNegocioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _documentoPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreNegocioController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _seleccionarDocumento() {
    setState(() {
      _documentoPath = 'documento_identidad_adjunto.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documento adjuntado correctamente'),
        backgroundColor: Color(0xFFD64E28),
      ),
    );
  }

  void _enviarSolicitud() async {
    if (_formKey.currentState!.validate()) {
      if (_documentoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor adjunta la foto de tu CI o NIT'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulación de envío a la base de datos
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFFD64E28)),
              SizedBox(width: 8),
              Text('Solicitud Enviada'),
            ],
          ),
          content: const Text(
            'Tu postulación de negocio ha sido enviada con éxito y está pendiente de revisión.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarFormulario();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Color(0xFFD64E28),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _limpiarFormulario() {
    _nombreNegocioController.clear();
    _descripcionController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    setState(() {
      _documentoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Negocios'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFD64E28),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono institucional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 48,
                    color: Color(0xFFD64E28),
                  ),
                ),
                const SizedBox(height: 12),

                // Encabezados
                Text(
                  'Postula tu Negocio',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD64E28),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra tu restaurante, casera o puesto tradicional',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Campos del Formulario
                TextFormField(
                  controller: _nombreNegocioController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del negocio o puesto',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del negocio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono de contacto',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un número de contacto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección o ubicación del puesto',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la dirección exacta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción del negocio',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Proporciona una breve descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Botón para adjuntar documento
                InkWell(
                  onTap: _seleccionarDocumento,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD64E28).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFFD64E28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _documentoPath ??
                                'Adjuntar Documento de Identidad (CI / NIT)',
                            style: TextStyle(
                              color: _documentoPath != null
                                  ? Colors.black87
                                  : Colors.black54,
                              fontWeight: _documentoPath != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _documentoPath != null
                              ? Icons.check_circle
                              : Icons.upload_file_rounded,
                          color: const Color(0xFFD64E28),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Botón principal de envío
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarSolicitud,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD64E28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Enviar Solicitud',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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