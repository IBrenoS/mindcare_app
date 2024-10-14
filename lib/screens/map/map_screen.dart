import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final ApiService _apiService = ApiService();

  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _hasError = false;

  // Variáveis para filtros e paginação
  String? _selectedServiceType; // CRAS ou Clínicas
  String? _selectedEstablishmentType; // Público ou Privado
  int _currentPage = 1;
  int _totalPages = 1;

  // Variáveis para o painel inferior
  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndData();
  }

  Future<void> _initializeLocationAndData() async {
    await _getUserLocation();
    await _loadSupportPoints();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se os serviços de localização estão habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Verificar permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Obter a posição atual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  // Verificar o valor das queries baseado no filtro selecionado
  Future<void> _loadSupportPoints() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Determinar o tipo de serviço para a query
      List<String> queries = [];
      if (_selectedServiceType == null || _selectedServiceType == 'Todos') {
        queries = ['CRAS', 'Clínicas de Saúde Mental'];
      } else if (_selectedServiceType == 'CRAS') {
        queries = ['CRAS'];
      } else if (_selectedServiceType == 'Clínicas') {
        queries = ['Clínicas de Saúde Mental'];
      }

      final data = await _apiService.getNearbySupportPoints(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        queries: queries,
        page: _currentPage,
        limit: 20,
        type: _selectedEstablishmentType,
      );

      List<dynamic> results = data['results'];
      _totalPages = data['totalPages'];

      Set<Marker> markers = Set();

      for (var point in results) {
        try {
          final lat = point['position']['lat'];
          final lng = point['position']['lng'];

          if (lat != null && lng != null) {
            markers.add(
              Marker(
                markerId: MarkerId(point['id']),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: point['title'] ?? 'Título não disponível',
                  snippet: point['address'] ?? 'Endereço não disponível',
                  onTap: () {
                    _onMarkerTapped(point);
                  },
                ),
                onTap: () {
                  _onMapMarkerTapped(LatLng(lat, lng));
                },
              ),
            );
          } else {
            print('Coordenadas inválidas para o ponto: ${point['id']}');
          }
        } catch (e) {
          print('Erro ao criar marcador para o ponto ${point['id']}: $e');
        }
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar pontos de apoio: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14,
        ),
      );
    }
  }

  void _onMapMarkerTapped(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 17),
    );
  }

  // Exibir painel com informações detalhadas do marcador
  void _onMarkerTapped(Map<String, dynamic> point) {
    setState(() {
      _selectedPlace = point;
    });
    _showBottomSheet();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (_selectedPlace == null) return SizedBox.shrink();

        final List<dynamic>? photos = _selectedPlace!['photos'];

        return FractionallySizedBox(
          heightFactor: 0.5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPlace!['title'] ?? 'Informação não disponível',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(_selectedPlace!['address'] ?? 'Endereço não disponível'),
                  SizedBox(height: 8),
                  Text(
                      "Horário: ${_selectedPlace!['opening_hours'] != null ? _selectedPlace!['opening_hours']['status'] : 'Informação não disponível'}"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Avaliação: ${_selectedPlace!['rating'] ?? 'N/A'}"),
                      SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (photos != null && photos.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          final photoUrl = photos[index]['url'];

                          if (photoUrl != null) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.network(photoUrl),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    )
                  else
                    Text('Sem fotos disponíveis'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final lat = _selectedPlace!['position']['lat'];
                      final lng = _selectedPlace!['position']['lng'];
                      final url =
                          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Não foi possível abrir o Google Maps');
                      }
                    },
                    child: Text("Obter Direções"),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final lat = _selectedPlace!['position']['lat'];
                      final lng = _selectedPlace!['position']['lng'];
                      final url =
                          'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng';

                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Não foi possível abrir o Street View');
                      }
                    },
                    child: Text("Abrir Street View"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Funções para lidar com filtros e paginação
  void _onServiceTypeChanged(String? newServiceType) {
    setState(() {
      _selectedServiceType = newServiceType;
      _currentPage = 1;
    });
    _loadSupportPoints();
  }

  void _onEstablishmentTypeChanged(String? newEstablishmentType) {
    setState(() {
      _selectedEstablishmentType = newEstablishmentType;
      _currentPage = 1;
    });
    _loadSupportPoints();
  }

  void _onPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadSupportPoints();
    }
  }

  void _onNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _loadSupportPoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Pontos de Apoio'),
      ),
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : _hasError
                  ? Center(
                      child: Text(
                        'Erro ao carregar pontos de apoio.',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        zoom: 14,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildFilterControls(),
          ),
          Positioned(
            bottom: 100,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                        ),
                      );
                    }
                  },
                  mini: true,
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _mapController?.animateCamera(
                    CameraUpdate.zoomIn(),
                  ),
                  mini: true,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _mapController?.animateCamera(
                    CameraUpdate.zoomOut(),
                  ),
                  mini: true,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: _buildPaginationControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedServiceType,
                isExpanded: true,
                hint: Text('Tipo de Serviço'),
                items: [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: 'CRAS', child: Text('CRAS')),
                  DropdownMenuItem(value: 'Clínicas', child: Text('Clínicas')),
                ],
                onChanged: _onServiceTypeChanged,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedEstablishmentType,
                isExpanded: true,
                hint: Text('Tipo de Estabelecimento'),
                items: [
                  DropdownMenuItem(value: null, child: Text('Padrão')),
                  DropdownMenuItem(value: 'public', child: Text('Público')),
                  DropdownMenuItem(value: 'private', child: Text('Privado')),
                ],
                onChanged: _onEstablishmentTypeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _currentPage > 1 ? _onPreviousPage : null,
          child: Text('Anterior'),
        ),
        SizedBox(width: 20),
        Text('Página $_currentPage de $_totalPages'),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: _currentPage < _totalPages ? _onNextPage : null,
          child: Text('Próximo'),
        ),
      ],
    );
  }
}
