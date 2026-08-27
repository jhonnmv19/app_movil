import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/establecimiento_service.dart';
import '../../../data/models/usuario_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  Timer? _debounceTimer;

  UsuarioModel? _usuario;
  List<Map<String, dynamic>> _platillos = [];
  Set<int> _favoritosIds = {};
  bool _isLoading = true;
  
  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todos';
  double _precioMaximo = 100.0;

  final List<String> _categorias = [
    'Todos', 'Sopas', 'Segundos', 'Pique', 'Chicharrón', 'Postres'
  ];

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

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    final user = await _service.obtenerPerfilUsuarioActual();
    
    if (user != null) {
      final favs = await _service.obtenerIdsFavoritos(user.id);
      _favoritosIds = favs.toSet();
    }

    await _fetchPlatillos();

    if (mounted) {
      setState(() {
        _usuario = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPlatillos() async {
    final platillosData = await _service.obtenerPlatosPopulares(
      query: _searchQuery,
      categoria: _categoriaSeleccionada,
      precioMaximo: _precioMaximo,
    );

    if (mounted) {
      setState(() {
        _platillos = platillosData;
      });
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
    setState(() => _categoriaSeleccionada = categoria);
    _fetchPlatillos();
  }

  void _toggleFav(int establecimientoId) async {
    if (_usuario == null || establecimientoId == 0) return;
    final esFav = _favoritosIds.contains(establecimientoId);

    setState(() {
      if (esFav) {
        _favoritosIds.remove(establecimientoId);
      } else {
        _favoritosIds.add(establecimientoId);
      }
    });

    await _service.toggleFavorito(_usuario!.id, establecimientoId, !esFav);
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
              // Header con saludo y Avatar estilizado
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${_usuario?.nombreCompleto.split(" ").first ?? "Comensal"}! 👋',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primaryOrange.withOpacity(0.15),
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

              // Buscador y Filtro Modal
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

              // Barra de Categorías en Chips
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

              // Título de Sección
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

              // Lista de Platos o Indicador de Carga
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                        ),
                      ),
                    )
                  : _platillos.isEmpty
                      ? SliverToBoxAdapter(
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
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _platillos[index];
                              final est = item['establecimientos_r_sabor'];
                              final int estId = est?['id'] ?? 0;
                              final bool esFavorito = _favoritosIds.contains(estId);

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 1.5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Image.network(
                                          item['imagen_url'] ?? '',
                                          height: 170,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 170,
                                            color: Colors.orange.shade50,
                                            child: const Center(
                                              child: Icon(Icons.restaurant, size: 50, color: AppTheme.primaryOrange),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Material(
                                            color: Colors.white,
                                            shape: const CircleBorder(),
                                            elevation: 2,
                                            child: IconButton(
                                              constraints: const BoxConstraints(),
                                              icon: Icon(
                                                esFavorito ? Icons.favorite : Icons.favorite_border,
                                                color: esFavorito ? Colors.red : Colors.grey[600],
                                                size: 20,
                                              ),
                                              onPressed: () => _toggleFav(estId),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.75),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Bs. ${(item['precio_bs'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                              style: const TextStyle(
                                                color: Colors.white, 
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['nombre'] ?? 'Platillo Sin Nombre',
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                                  Text(
                                                    ' ${(est?['calificacion_promedio'] ?? 5.0)}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${est?['nombre_comercial'] ?? 'Local'} • ${est?['direccion_texto'] ?? 'Cochabamba'}',
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
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

  void _mostrarModalFiltros(BuildContext context) {
    double tempPrecio = _precioMaximo;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por Precio', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Precio Máximo:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        'Bs. ${tempPrecio.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempPrecio,
                    min: 5,
                    max: 150,
                    divisions: 29,
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) {
                      setModalState(() => tempPrecio = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _precioMaximo = tempPrecio);
                        _fetchPlatillos();
                        Navigator.pop(modalContext);
                      },
                      child: const Text(
                        'Aplicar Filtro', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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
}