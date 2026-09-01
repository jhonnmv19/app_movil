// lib/presentation/screens/duenno/requests_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/establecimiento_service.dart';

class RequestsScreen extends StatefulWidget {
  final int establecimientoId;

  const RequestsScreen({
    super.key,
    required this.establecimientoId,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = EstablecimientoService();
  final _picker = ImagePicker();

  bool _isLoading = false;

  // Formulario - Plato del Día
  final _formKeyPlatoDia = GlobalKey<FormState>();
  final _tituloPlatoDiaController = TextEditingController();
  final _descPlatoDiaController = TextEditingController();
  final _precioPlatoDiaController = TextEditingController();
  bool _disponiblePlatoDia = true;

  // Formulario - Platillo Regular (Menú)
  final _formKeyPlatillo = GlobalKey<FormState>();
  final _nombrePlatilloController = TextEditingController();
  final _descPlatilloController = TextEditingController();
  final _precioPlatilloController = TextEditingController();
  int? _categoriaSeleccionadaId;
  File? _imagenPlatilloSeleccionada;

  // Listas de datos
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _misPlatillos = [];
  List<Map<String, dynamic>> _misPlatosDia = [];
  List<Map<String, dynamic>> _misFotosGaleria = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloPlatoDiaController.dispose();
    _descPlatoDiaController.dispose();
    _precioPlatoDiaController.dispose();
    _nombrePlatilloController.dispose();
    _descPlatilloController.dispose();
    _precioPlatilloController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _service.obtenerCategorias();
      final platillos = await _service.obtenerPlatillosPorEstablecimiento(widget.establecimientoId);
      final platosDia = await _service.obtenerPlatosDelDiaPorEstablecimiento(widget.establecimientoId);
      final fotos = await _service.obtenerFotosEstablecimiento(widget.establecimientoId);

      if (!mounted) return;

      setState(() {
        _categorias = cats;
        _misPlatillos = platillos;
        _misPlatosDia = platosDia;
        _misFotosGaleria = fotos;
        if (_categorias.isNotEmpty && _categoriaSeleccionadaId == null) {
          _categoriaSeleccionadaId = _categorias.first['id'] as int;
        }
      });
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error cargando información general.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- SELECCIÓN DE IMÁGENES ---
  Future<void> _seleccionarImagenPlatillo() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imagenPlatilloSeleccionada = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) _mostrarMensaje('No se pudo acceder a la galería o se denegó el permiso.', Colors.red);
    }
  }

  Future<void> _subirFotoGaleria() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final archivo = File(pickedFile.path);
      final pathName = 'establecimientos/${widget.establecimientoId}/galeria_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final publicUrl = await _service.subirImagen(
        fileBytes: archivo,
        bucket: 'imagenes_r_sabor',
        path: pathName,
      );

      if (publicUrl != null) {
        await _service.agregarFotoEstablecimiento(
          establecimientoId: widget.establecimientoId,
          imagenUrl: publicUrl,
        );
        if (mounted) {
          _mostrarMensaje('Foto añadida a la galería con éxito', const Color(0xFFD64E28));
        }
        await _cargarDatosIniciales();
      }
    } catch (e) {
      if (mounted) _mostrarMensaje('Error al subir la imagen.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ACCIONES DE PUBLICACIÓN ---
  Future<void> _guardarPlatillo() async {
    FocusScope.of(context).unfocus();
    if (!(_formKeyPlatillo.currentState?.validate() ?? false)) return;
    if (_categoriaSeleccionadaId == null) {
      _mostrarMensaje('Selecciona una categoría válida.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imagenUrl;
      if (_imagenPlatilloSeleccionada != null) {
        final pathName = 'platillos/est_${widget.establecimientoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imagenUrl = await _service.subirImagen(
          fileBytes: _imagenPlatilloSeleccionada!,
          bucket: 'imagenes_r_sabor',
          path: pathName,
        );
      }

      final precio = double.parse(_precioPlatilloController.text.trim().replaceAll(',', '.'));

      await _service.crearPlatillo(
        establecimientoId: widget.establecimientoId,
        categoriaPlatilloId: _categoriaSeleccionadaId!,
        nombre: _nombrePlatilloController.text.trim(),
        descripcion: _descPlatilloController.text.trim(),
        precioBs: precio,
        imagenUrl: imagenUrl,
      );

      _nombrePlatilloController.clear();
      _descPlatilloController.clear();
      _precioPlatilloController.clear();
      setState(() => _imagenPlatilloSeleccionada = null);

      if (mounted) {
        _mostrarMensaje('¡Platillo agregado al menú!', const Color(0xFFD64E28));
      }
      await _cargarDatosIniciales();
    } catch (e) {
      if (mounted) _mostrarMensaje('Error al guardar el platillo.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _publicarPlatoDelDia() async {
    FocusScope.of(context).unfocus();
    if (!(_formKeyPlatoDia.currentState?.validate() ?? false)) return;

    final precio = double.tryParse(_precioPlatoDiaController.text.trim().replaceAll(',', '.'));
    if (precio == null || precio <= 0) {
      _mostrarMensaje('Ingresa un precio válido.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.publicarPlatoDelDia(
        establecimientoId: widget.establecimientoId,
        tituloOferta: _tituloPlatoDiaController.text.trim(),
        descripcionOferta: _descPlatoDiaController.text.trim(),
        precioOfertaBs: precio,
        disponibleAhora: _disponiblePlatoDia,
      );

      _tituloPlatoDiaController.clear();
      _descPlatoDiaController.clear();
      _precioPlatoDiaController.clear();
      setState(() => _disponiblePlatoDia = true);

      if (mounted) {
        _mostrarMensaje('¡Plato del día publicado!', const Color(0xFFD64E28));
      }
      await _cargarDatosIniciales();
    } catch (e) {
      if (mounted) _mostrarMensaje('Error al publicar la oferta.', Colors.red);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD64E28);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Actualizar datos',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _cargarDatosIniciales,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.star_rounded), text: 'Plato del Día'),
            Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Añadir Platillo'),
            Tab(icon: Icon(Icons.collections_rounded), text: 'Fotos Local'),
            Tab(icon: Icon(Icons.visibility_rounded), text: 'Vista Comensal'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading && _misPlatillos.isEmpty
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTabPlatoDelDia(primaryColor),
                  _buildTabNuevoPlatillo(primaryColor),
                  _buildTabFotosGaleria(primaryColor),
                  _buildTabVistaComensal(primaryColor),
                ],
              ),
      ),
    );
  }

  // --- TAB 1: PLATO DEL DÍA ---
  Widget _buildTabPlatoDelDia(Color primaryColor) {
    return Form(
      key: _formKeyPlatoDia,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Oferta Especial de Hoy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          const Text('Destaca el plato principal que ofrecerás hoy en el feed del comensal.'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _tituloPlatoDiaController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('Título de la oferta', 'Ej. Picante de Pollo Especial', Icons.restaurant_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el título' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _precioPlatoDiaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))],
            decoration: _inputDecoration('Precio Promocional (Bs)', 'Ej. 20.00', Icons.attach_money_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el precio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descPlatoDiaController,
            maxLines: 3,
            maxLength: 250,
            decoration: _inputDecoration('Detalles del menú / Sopas', 'Ej. Incluye sopa de maní y refresco', Icons.notes_rounded),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Disponible para servir ahora', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Los comensales podrán visualizar este plato activo.'),
            activeTrackColor: primaryColor,
            value: _disponiblePlatoDia,
            onChanged: _isLoading ? null : (v) => setState(() => _disponiblePlatoDia = v),
          ),
          const SizedBox(height: 20),
          _buildButton('Publicar Oferta del Día', _publicarPlatoDelDia, primaryColor),
        ],
      ),
    );
  }

  // --- TAB 2: AÑADIR PLATILLO A LA CARTA ---
  Widget _buildTabNuevoPlatillo(Color primaryColor) {
    return Form(
      key: _formKeyPlatillo,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Nuevo Platillo en Menú',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_categorias.isNotEmpty)
            DropdownButtonFormField<int>(
              initialValue: _categoriaSeleccionadaId,
              decoration: _inputDecoration('Categoría de Menú', '', Icons.category_rounded),
              items: _categorias.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat['id'] as int,
                  child: Text(cat['nombre'].toString()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _categoriaSeleccionadaId = val),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nombrePlatilloController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('Nombre del Platillo', 'Ej. Majadito de Charque', Icons.fastfood_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _precioPlatilloController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))],
            decoration: _inputDecoration('Precio (Bs)', 'Ej. 25.00', Icons.sell_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el precio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descPlatilloController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('Descripción e ingredientes', 'Ej. Acompañado de huevo frito y plátano', Icons.description_rounded),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _seleccionarImagenPlatillo,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imagenPlatilloSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_imagenPlatilloSeleccionada!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Toca para seleccionar foto del plato', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildButton('Guardar en Menú', _guardarPlatillo, primaryColor),
        ],
      ),
    );
  }

  // --- TAB 3: GALERÍA DE FOTOS DEL LOCAL ---
  Widget _buildTabFotosGaleria(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Galería del Establecimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton.filled(
              onPressed: _isLoading ? null : _subirFotoGaleria,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              style: IconButton.styleFrom(backgroundColor: primaryColor),
            )
          ],
        ),
        const SizedBox(height: 16),
        _misFotosGaleria.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No has subido fotos de tu local aún.')),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _misFotosGaleria.length,
                itemBuilder: (context, index) {
                  final item = _misFotosGaleria[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['imagen_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  // --- TAB 4: VISTA DE CLIENTES Y MI CARTA ---
  Widget _buildTabVistaComensal(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Lo que Ven los Comensales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(height: 16),
        const Text('OFERTAS DEL DÍA ACTIVAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        if (_misPlatosDia.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Sin platos del día activos.', style: TextStyle(color: Colors.grey)),
          ),
        ..._misPlatosDia.map((pd) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.15),
                  child: Icon(Icons.bolt, color: primaryColor),
                ),
                title: Text(pd['titulo_oferta'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(pd['descripcion_oferta'] ?? ''),
                trailing: Text('${pd['precio_oferta_bs']} Bs', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )),
        const SizedBox(height: 20),
        const Text('PLATILLOS EN LA CARTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        if (_misPlatillos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No hay platillos registrados en la carta.', style: TextStyle(color: Colors.grey)),
          ),
        ..._misPlatillos.map((pl) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: pl['imagen_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(pl['imagen_url'], width: 50, height: 50, fit: BoxFit.cover),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                title: Text(pl['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${pl['precio_bs']} Bs - ${pl['categorias_platillos_r_sabor']?['nombre'] ?? 'Sin categoría'}'),
              ),
            )),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD64E28), width: 2)),
    );
  }
}