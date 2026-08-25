import 'package:flutter/material.dart';

class PublishDailyDishScreen extends StatefulWidget {
  final int establecimientoId;

  const PublishDailyDishScreen({super.key, required this.establecimientoId});

  @override
  State<PublishDailyDishScreen> createState() => _PublishDailyDishScreenState();
}

class _PublishDailyDishScreenState extends State<PublishDailyDishScreen> {
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

  void _publicarPlatoDelDia() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Mapeo según la tabla: plato_del_dia_r_sabor
      final datosPlatoDia = {
        'establecimiento_id': widget.establecimientoId,
        'titulo_oferta': _tituloController.text.trim(),
        'descripcion_oferta': _descripcionController.text.trim(),
        'precio_oferta_bs': double.tryParse(_precioOfertaController.text.trim()) ?? 0.0,
        'disponible_ahora': _disponibleAhora,
      };

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Plato del día publicado exitosamente!'),
          backgroundColor: Color(0xFFD64E28),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Plato del Día'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oferta de Hoy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD64E28),
                      ),
                ),
                const SizedBox(height: 4),
                const Text('Completa los detalles del plato especial que ofrecerás hoy a tus comensales.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título del plato u oferta',
                    hintText: 'Ej. Silpancho Cochabambino, Sopa de Maní',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre del plato' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioOfertaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Precio de oferta (Bs)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
                    if (double.tryParse(v.trim()) == null) return 'Ingresa un monto válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción / Guarniciones',
                    hintText: 'Ej. Incluye arroz, papa frita, ensalada y refresco gratis',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Disponible para servir ahora'),
                  activeColor: const Color(0xFFD64E28),
                  value: _disponibleAhora,
                  onChanged: (val) => setState(() => _disponibleAhora = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _publicarPlatoDelDia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD64E28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Publicar Plato del Día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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