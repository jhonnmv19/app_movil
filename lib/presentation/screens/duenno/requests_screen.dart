import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsScreen extends StatefulWidget {
  final int establecimientoId;

  const RequestsScreen({
    super.key,
    required this.establecimientoId,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioOfertaController = TextEditingController();

  bool _disponibleAhora = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioOfertaController.dispose();
    super.dispose();
  }

  Future<void> _publicarPlatoDelDia() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final precio = double.tryParse(
      _precioOfertaController.text.trim().replaceAll(',', '.'),
    );

    if (precio == null || precio <= 0) {
      _mostrarMensaje(
        'Ingresa un precio válido mayor a cero.',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client
          .from('plato_del_dia_r_sabor')
          .insert({
        'establecimiento_id': widget.establecimientoId,
        'titulo_oferta': _tituloController.text.trim(),
        'descripcion_oferta': _descripcionController.text.trim(),
        'precio_oferta_bs': precio,
        'disponible_ahora': _disponibleAhora,
      });

      if (!mounted) return;

      _tituloController.clear();
      _descripcionController.clear();
      _precioOfertaController.clear();

      setState(() => _disponibleAhora = true);

      _mostrarMensaje(
        '¡Plato del día publicado exitosamente!',
        const Color(0xFFD64E28),
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        'Error al publicar la oferta.',
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD64E28);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Plato del Día'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Limpiar formulario',
            onPressed: _isLoading
                ? null
                : () {
                    _tituloController.clear();
                    _descripcionController.clear();
                    _precioOfertaController.clear();
                    setState(() => _disponibleAhora = true);
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Oferta de Hoy',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completa los detalles del plato especial que ofrecerás hoy a tus comensales.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Título del plato u oferta',
                  hint: 'Ej. Silpancho Cochabambino',
                  icon: Icons.restaurant_menu_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del plato';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre es demasiado corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioOfertaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*[,.]?\d{0,2}'),
                  ),
                ],
                decoration: _inputDecoration(
                  label: 'Precio de oferta (Bs)',
                  hint: 'Ej. 25.00',
                  icon: Icons.attach_money_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el precio';
                  }

                  final precio = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );

                  if (precio == null || precio <= 0) {
                    return 'Ingresa un monto válido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                maxLength: 250,
                decoration: _inputDecoration(
                  label: 'Descripción / Guarniciones',
                  hint: 'Ej. Incluye arroz, papa frita y ensalada',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Disponible para servir ahora',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Los comensales podrán ver que está disponible.',
                ),
                activeColor: primaryColor,
                value: _disponibleAhora,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _disponibleAhora = value);
                      },
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _publicarPlatoDelDia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryColor.withOpacity(.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Publicar Plato del Día',
                            key: ValueKey('label'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD64E28),
          width: 2,
        ),
      ),
    );
  }
}