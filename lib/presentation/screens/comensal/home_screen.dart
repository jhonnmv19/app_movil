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
  
  UsuarioModel? _usuario;
  List<Map<String, dynamic>> _platillos = [];
  Set<int> _favoritosIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todos';

  final List<String> _categorias = ['Todos', 'Sopas', 'Segundos', 'Pique', 'Chicharrón', 'Postres'];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    final user = await _service.obtenerPerfilUsuarioActual();
    if (user != null) {
      final favs = await _service.obtenerIdsFavoritos(user.id);
      _favoritosIds = favs.toSet();
    }
    
    final platillosData = await _service.obtenerPlatosPopulares(query: _searchQuery);

    setState(() {
      _usuario = user;
      _platillos = platillosData;
      _isLoading = false;
    });
  }

  void _filtrarBusqueda(String val) async {
    _searchQuery = val;
    final platillosData = await _service.obtenerPlatosPopulares(query: _searchQuery);
    setState(() {
      _platillos = platillosData;
    });
  }

  void _toggleFav(int establecimientoId) async {
    if (_usuario == null) return;
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
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarDatosIniciales,
          child: CustomScrollView(
            slivers: [
              // Encabezado con Saludo y Avatar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${_usuario?.nombreCompleto.split(" ").first ?? "Comensal"}! 👋',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¿Qué quieres comer hoy en Cochabamba?',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryOrange,
                        child: Text(
                          _usuario?.nombreCompleto.isNotEmpty == true
                              ? _usuario!.nombreCompleto[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Buscador y Botón Filtro
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: _filtrarBusqueda,
                          decoration: InputDecoration(
                            hintText: 'Buscar platos, caseritas o restaurantes...',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            _mostrarModalFiltros(context);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Categorías Rápidas
              SliverToBoxAdapter(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              _categoriaSeleccionada = cat;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Título de Sección
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text('Platos Destacados & Populares', style: Theme.of(context).textTheme.titleLarge),
                ),
              ),

              // Listado de Platos
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                    )
                  : _platillos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No se encontraron platos o locales disponibles.'),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Image.network(
                                          item['imagen_url'] ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 160,
                                            color: AppTheme.accentLightOrange,
                                            child: const Icon(Icons.fastfood, size: 60, color: AppTheme.primaryOrange),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: Icon(
                                                esFavorito ? Icons.favorite : Icons.favorite_border,
                                                color: esFavorito ? Colors.red : Colors.grey,
                                              ),
                                              onPressed: () => _toggleFav(estId),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Bs. ${(item['precio_bs'] as num).toStringAsFixed(2)}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['nombre'] ?? '',
                                                  style: Theme.of(context).textTheme.titleLarge,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                                  Text(' ${(est?['calificacion_promedio'] ?? 5.0)}'),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '📍 ${est?['nombre_comercial'] ?? 'Restaurante'} • ${est?['direccion_texto'] ?? 'Cochabamba'}',
                                            style: Theme.of(context).textTheme.bodySmall,
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtrar Búsqueda', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Text('Rango de Precio Máximo:'),
              Slider(
                value: 30,
                min: 5,
                max: 100,
                divisions: 19,
                activeColor: AppTheme.primaryOrange,
                label: '30 Bs',
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar Filtros'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}