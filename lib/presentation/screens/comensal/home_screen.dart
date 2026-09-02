import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/establecimiento_service.dart';
import '../../../data/services/favoritos_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/models/usuario_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  final FavoritosService _favoritosService = FavoritosService();
  final SessionService _sessionService = SessionService();
  Timer? _debounceTimer;

  UsuarioModel? _usuario;
  List<Map<String, dynamic>> _platillos = [];
  Set<String> _platillosFavoritosIds = {};

  bool _isLoading = true;
  bool _isFetchingPlatillos = false;

  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todos';
  double _precioMaximo = 100.0;

  List<String> _categorias = ['Todos'];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Helper seguro para extraer el ID
  String? _obtenerIdUnico(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // Helper seguro para parsear Precios
  double _parsePrecio(Map<String, dynamic> item, {List<String>? keys}) {
    final candidateKeys = keys ?? ['precio_bs', 'precio', 'precio_plato', 'precio_unidad', 'costo'];
    dynamic rawValue;
    for (var key in candidateKeys) {
      if (item.containsKey(key) && item[key] != null) {
        rawValue = item[key];
        break;
      }
    }

    if (rawValue is num) return rawValue.toDouble();
    if (rawValue is String) return double.tryParse(rawValue) ?? 0.0;
    return 0.0;
  }

  Future<void> _cargarDatosIniciales() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Obtención de usuario desde SessionService con fallback al servicio
      UsuarioModel? user = _sessionService.usuarioActual;
      user ??= await _service.obtenerPerfilUsuarioActual();

      // 2. Si se recuperó sesión, guardar en el Singleton y cargar favoritos
      if (user != null) {
        _sessionService.iniciarSesion(user);
        final favs = await _favoritosService.obtenerIdsPlatillosFavoritos(user.id);
        _platillosFavoritosIds = favs.map((e) => e.toString()).toSet();
      } else {
        _platillosFavoritosIds.clear();
      }

      // 3. Cargar platillos iniciales
      final platillosData = await _service.obtenerPlatosPopulares(
        query: _searchQuery,
        categoria: _categoriaSeleccionada,
        precioMaximo: _precioMaximo,
      );

      // 4. Cargar categorías dinámicas
      try {
        final dynamic categoriasBDRaw = await _service.obtenerCategorias();
        if (categoriasBDRaw is List && categoriasBDRaw.isNotEmpty) {
          final List<String> categoriasParseadas = categoriasBDRaw.map((e) {
            if (e is Map) {
              return e['nombre']?.toString() ?? e.values.first.toString();
            }
            return e.toString();
          }).where((nombre) => nombre.isNotEmpty).toList();

          _categorias = ['Todos', ...categoriasParseadas];
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _usuario = user;
          _platillos = platillosData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar la información inicial')),
        );
      }
    }
  }

  Future<void> _fetchPlatillos() async {
    if (!mounted) return;
    setState(() => _isFetchingPlatillos = true);

    try {
      final platillosData = await _service.obtenerPlatosPopulares(
        query: _searchQuery,
        categoria: _categoriaSeleccionada,
        precioMaximo: _precioMaximo,
      );

      if (mounted) {
        setState(() {
          _platillos = platillosData;
          _isFetchingPlatillos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingPlatillos = false);
      }
    }
  }

  void _onSearchChanged(String val) {
    _searchQuery = val;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchPlatillos();
    });
  }

  void _onCategoriaSelected(String categoria) {
    if (_categoriaSeleccionada == categoria) return;
    setState(() => _categoriaSeleccionada = categoria);
    _fetchPlatillos();
  }

  void _toggleFav(dynamic rawPlatilloId) async {
    final String? platilloIdStr = _obtenerIdUnico(rawPlatilloId);
    final int? platilloIdInt = platilloIdStr != null ? int.tryParse(platilloIdStr) : null;

    final usuarioActual = _usuario ?? _sessionService.usuarioActual;

    if (usuarioActual == null || platilloIdInt == null) {
      if (_usuario != null || _platillosFavoritosIds.isNotEmpty) {
        setState(() {
          _usuario = null;
          _platillosFavoritosIds.clear();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para guardar favoritos.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final String idClave = platilloIdInt.toString();
    final bool esFav = _platillosFavoritosIds.contains(idClave);

    // Actualización optimista de la UI
    setState(() {
      if (esFav) {
        _platillosFavoritosIds.remove(idClave);
      } else {
        _platillosFavoritosIds.add(idClave);
      }
    });

    // Llamada al servicio con los parámetros correctos
    final exito = await _favoritosService.toggleFavoritoPlatillo(
      comensalId: usuarioActual.id,
      platilloId: platilloIdInt,
      esFavoritoActualmente: esFav,
    );

    // Revertir cambio en caso de falla en backend
    if (!exito && mounted) {
      setState(() {
        if (esFav) {
          _platillosFavoritosIds.add(idClave);
        } else {
          _platillosFavoritosIds.remove(idClave);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar tus favoritos.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _mostrarModalFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        double tempPrecio = _precioMaximo;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar Resultados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Precio Máximo: Bs. ${tempPrecio.toStringAsFixed(0)}'),
                  Slider(
                    value: tempPrecio,
                    min: 10.0,
                    max: 200.0,
                    divisions: 19,
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) {
                      setModalState(() => tempPrecio = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _precioMaximo = tempPrecio;
                        });
                        Navigator.pop(modalContext);
                        _fetchPlatillos();
                      },
                      child: const Text('Aplicar Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarDatosIniciales,
          color: AppTheme.primaryOrange,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, ${_usuario?.nombreCompleto.isNotEmpty == true ? _usuario!.nombreCompleto.split(" ").first : "Comensal"}! 👋',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¿Qué vas a comer hoy en Cochabamba?',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
                        child: Text(
                          _usuario?.nombreCompleto.isNotEmpty == true
                              ? _usuario!.nombreCompleto[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Buscador y Botón de Filtro
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar platos o restaurantes...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.primaryOrange),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _mostrarModalFiltros(context),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.tune, color: Colors.white, size: 26),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Categorías
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categorias.length,
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final isSelected = _categoriaSeleccionada == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryOrange,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade300,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (_) => _onCategoriaSelected(cat),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Encabezado
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Text(
                    'Platos Destacados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // Lista de Platillos
              if (_isLoading || _isFetchingPlatillos)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                    ),
                  ),
                )
              else if (_platillos.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Sin resultados',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No encontramos platillos con los criterios aplicados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _platillos[index];

                      final dynamic rawId = item['id'] ?? item['platillo_id'];
                      final String? platilloIdStr = _obtenerIdUnico(rawId);
                      final double precio = _parsePrecio(item);
                      final bool esFavorito = platilloIdStr != null && _platillosFavoritosIds.contains(platilloIdStr);

                      final est = item['establecimientos_r_sabor'] as Map<String, dynamic>?;
                      final double calificacion = est != null ? _parsePrecio(est, keys: ['calificacion', 'rating', 'puntuacion']) : 5.0;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              if (est != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/mapa',
                                  arguments: {
                                    'establecimientoId': est['id'],
                                    'latitud': est['latitud'],
                                    'longitud': est['longitud'],
                                    'nombre': est['nombre_comercial'],
                                  },
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        item['imagen_url'] ?? item['url_imagen'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Material(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        child: IconButton(
                                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                          icon: Icon(
                                            esFavorito ? Icons.favorite : Icons.favorite_border,
                                            color: esFavorito ? Colors.red : Colors.grey[700],
                                            size: 22,
                                          ),
                                          onPressed: () => _toggleFav(rawId),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nombre'] ?? item['nombre_plato'] ?? 'Platillo',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Bs. ${precio.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryOrange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 18),
                                              const SizedBox(width: 4),
                                              Text(
                                                calificacion.toStringAsFixed(1),
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _platillos.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}