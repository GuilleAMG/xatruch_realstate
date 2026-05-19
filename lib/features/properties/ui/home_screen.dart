// Pantalla principal: muestra el listado de propiedades disponibles
// con busqueda, filtros y ordenamiento por distancia.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/ui/create_property_screen.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/filter_modal.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_list_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sortByDistance = false;
  Position? _currentPosition;
  bool _isGettingLocation = false;
  String _searchQuery = '';
  bool _locationEnabled = true;
  final PropertyFilters _filters = PropertyFilters();

  @override
  void initState() {
    super.initState();
    _loadLocationPreference();
  }

  Future<void> _loadLocationPreference() async {
    final user = authService.currentUser;
    if (user == null) return;

    final userData = await userService.getUsuarioById(user.uid);
    if (!mounted) return;

    setState(() {
      _locationEnabled = userData?['locationEnabled'] as bool? ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xatruch Inmobiliaria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _sortByDistance ? Icons.location_on : Icons.location_off_outlined,
              color: _sortByDistance ? colorScheme.primary : null,
            ),
            onPressed: _toggleSortByDistance,
            tooltip: 'Ordenar por cercanía',
          ),
        ],
      ),
      body: _isGettingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obteniendo ubicación...'),
                ],
              ),
            )
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: PropertyListView(
                    searchQuery: _searchQuery,
                    filters: _filters,
                    sortByDistance: _sortByDistance,
                    currentPosition: _currentPosition,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (context) => const CreatePropertyScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Search Bar ──

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () async {
              await showFilterModal(
                context,
                filters: _filters,
                onFiltersChanged: () => setState(() {}),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Location Sort Toggle ──

  Future<void> _toggleSortByDistance() async {
    if (!_locationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La ubicación está desactivada en configuración.'),
          ),
        );
      }
      return;
    }

    if (_sortByDistance) {
      setState(() => _sortByDistance = false);
      return;
    }

    setState(() => _isGettingLocation = true);

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, active los servicios de ubicación')),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicación denegado')),
            );
          }
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Los permisos de ubicación están denegados permanentemente')),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _sortByDistance = true;
        _isGettingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
      setState(() => _isGettingLocation = false);
    }
  }
}
