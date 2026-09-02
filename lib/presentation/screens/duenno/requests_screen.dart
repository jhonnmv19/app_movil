import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
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

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EstablecimientoService _service = EstablecimientoService();
  final ImagePicker _picker = ImagePicker();

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

  // Selección de imagen multiplataforma
  XFile? _imagenPlatilloSeleccionada;

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
      final platillos = await _service.obtenerPlatillosPorEstablecimiento(
        widget.establecimientoId,
      );
      final platosDia = await _service.obtenerPlatosDelDiaPorEstablecimiento(
        widget.establecimientoId,
      );
      final fotos = await _service.obtenerFotosEstablecimiento(
        widget.establecimientoId,
      );

      if (!mounted) return;

      setState(() {
        _categorias = cats;
        _misPlatillos = platillos;
        _misPlatosDia = platosDia;
        _misFotosGaleria = fotos;
        if (_categorias.isNotEmpty && _categoriaSeleccionadaId == null) {
          _categoriaSeleccionadaId =
              int.tryParse(_categorias.first['id'].toString());
        }
      });
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al cargar la información general.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- SELECCIÓN Y SUBIDA DE IMÁGENES MULTIPLATAFORMA ---
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
          _imagenPlatilloSeleccionada = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('No se pudo acceder a la galería.', Colors.red);
      }
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

      final bytes = await pickedFile.readAsBytes();
      final pathName =
          'establecimientos/${widget.establecimientoId}/galeria_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final publicUrl = await _service.subirImagen(
        fileBytes: kIsWeb ? null : File(pickedFile.path),
        fileDataWeb: kIsWeb ? bytes : null,
        bucket: 'establecimientos-fotos',
        path: pathName,
      );

      if (publicUrl != null) {
        await _service.agregarFotoEstablecimiento(
          establecimientoId: widget.establecimientoId,
          imagenUrl: publicUrl,
        );
        if (mounted) {
          _mostrarMensaje(
            'Foto añadida a la galería con éxito',
            AppTheme.primaryOrange,
          );
        }
        await _cargarDatosIniciales();
      } else {
        if (mounted) {
          _mostrarMensaje('No se pudo obtener la URL de la imagen.', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al subir la imagen a la galería.', Colors.red);
      }
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
        final bytes = await _imagenPlatilloSeleccionada!.readAsBytes();
        final pathName =
            'platillos/est_${widget.establecimientoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        imagenUrl = await _service.subirImagen(
          fileBytes: kIsWeb ? null : File(_imagenPlatilloSeleccionada!.path),
          fileDataWeb: kIsWeb ? bytes : null,
          bucket: 'establecimientos-fotos',
          path: pathName,
        );
      }

      final precio = double.parse(
        _precioPlatilloController.text.trim().replaceAll(',', '.'),
      );

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
        _mostrarMensaje(
          '¡Platillo agregado al menú!',
          AppTheme.primaryOrange,
        );
      }
      await _cargarDatosIniciales();
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al guardar el platillo.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _publicarPlatoDelDia() async {
    FocusScope.of(context).unfocus();
    if (!(_formKeyPlatoDia.currentState?.validate() ?? false)) return;

    final precio = double.tryParse(
      _precioPlatoDiaController.text.trim().replaceAll(',', '.'),
    );
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
        _mostrarMensaje(
          '¡Plato del día publicado!',
          AppTheme.primaryOrange,
        );
      }
      await _cargarDatosIniciales();
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al publicar la oferta.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mensaje,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryOrange,
        surfaceTintColor: Colors.transparent,
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
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryOrange,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.star_rounded), text: 'Plato del Día'),
            Tab(
              icon: Icon(Icons.restaurant_menu_rounded),
              text: 'Añadir Platillo',
            ),
            Tab(icon: Icon(Icons.collections_rounded), text: 'Fotos Local'),
            Tab(icon: Icon(Icons.visibility_rounded), text: 'Vista Comensal'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading && _misPlatillos.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange,
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTabPlatoDelDia(),
                  _buildTabNuevoPlatillo(),
                  _buildTabFotosGaleria(),
                  _buildTabVistaComensal(),
                ],
              ),
      ),
    );
  }

  // --- TAB 1: PLATO DEL DÍA ---
  Widget _buildTabPlatoDelDia() {
    return Form(
      key: _formKeyPlatoDia,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Oferta Especial de Hoy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Destaca el plato principal que ofrecerás hoy en el feed del comensal.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _tituloPlatoDiaController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Título de la oferta',
              'Ej. Picante de Pollo Especial',
              Icons.restaurant_rounded,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa el título' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _precioPlatoDiaController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
            ],
            decoration: _inputDecoration(
              'Precio Promocional (Bs)',
              'Ej. 20.00',
              Icons.attach_money_rounded,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa el precio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descPlatoDiaController,
            maxLines: 3,
            maxLength: 250,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Detalles del menú / Sopas',
              'Ej. Incluye sopa de maní y refresco',
              Icons.notes_rounded,
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Disponible para servir ahora',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Los comensales podrán visualizar este plato activo.',
            ),
            activeTrackColor: AppTheme.primaryOrange,
            value: _disponiblePlatoDia,
            onChanged: _isLoading
                ? null
                : (v) => setState(() => _disponiblePlatoDia = v),
          ),
          const SizedBox(height: 20),
          _buildButton('Publicar Oferta del Día', _publicarPlatoDelDia),
        ],
      ),
    );
  }

  // --- TAB 2: AÑADIR PLATILLO A LA CARTA ---
  Widget _buildTabNuevoPlatillo() {
    return Form(
      key: _formKeyPlatillo,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Nuevo Platillo en Menú',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_categorias.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _categoriaSeleccionadaId,
              decoration: _inputDecoration(
                'Categoría de Menú',
                '',
                Icons.category_rounded,
              ),
              items: _categorias.map((cat) {
                final catId = int.tryParse(cat['id'].toString()) ?? 0;
                return DropdownMenuItem<int>(
                  value: catId,
                  child: Text(cat['nombre'].toString()),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => _categoriaSeleccionadaId = val),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nombrePlatilloController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Nombre del Platillo',
              'Ej. Majadito de Charque',
              Icons.fastfood_rounded,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _precioPlatilloController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
            ],
            decoration: _inputDecoration(
              'Precio (Bs)',
              'Ej. 25.00',
              Icons.sell_rounded,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa el precio' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descPlatilloController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Descripción e ingredientes',
              'Ej. Acompañado de huevo frito y plátano',
              Icons.description_rounded,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _seleccionarImagenPlatillo,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imagenPlatilloSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(
                              _imagenPlatilloSeleccionada!.path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.file(
                              File(_imagenPlatilloSeleccionada!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca para seleccionar foto del plato',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildButton('Guardar en Menú', _guardarPlatillo),
        ],
      ),
    );
  }

  // --- TAB 3: GALERÍA DE FOTOS DEL LOCAL ---
  Widget _buildTabFotosGaleria() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Galería del Establecimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton.filled(
              onPressed: _isLoading ? null : _subirFotoGaleria,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        _misFotosGaleria.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No has subido fotos de tu local aún.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
                      item['imagen_url'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  // --- TAB 4: VISTA DE CLIENTES Y MI CARTA ---
  Widget _buildTabVistaComensal() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Lo que Ven los Comensales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'OFERTAS DEL DÍA ACTIVAS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (_misPlatosDia.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Sin platos del día activos.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ..._misPlatosDia.map(
          (pd) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.accentLightOrange,
                child: Icon(Icons.bolt, color: AppTheme.primaryOrange),
              ),
              title: Text(
                pd['titulo_oferta'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(pd['descripcion_oferta'] ?? ''),
              trailing: Text(
                '${pd['precio_oferta_bs']} Bs',
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'PLATILLOS EN LA CARTA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (_misPlatillos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No hay platillos registrados en la carta.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ..._misPlatillos.map(
          (pl) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: pl['imagen_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pl['imagen_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
              title: Text(
                pl['nombre'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${pl['precio_bs']} Bs - ${pl['categorias_platillos_r_sabor']?['nombre'] ?? 'Sin categoría'}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
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
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint.isNotEmpty ? hint : null,
      prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
      ),
    );
  }
}