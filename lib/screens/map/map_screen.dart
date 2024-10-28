import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final ApiService apiService = ApiService();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isFilterVisible = false; // Inicialmente oculta
  String _selectedFilter = "Todos";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Solicita a permissão de localização
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização negada')),
      );
    }
  }

  // Obter a localização atual e carregar os pontos de apoio
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    _loadSupportPoints();
  }

  // Carrega os pontos de apoio próximos usando a API
  Future<void> _loadSupportPoints({String query = "Todos"}) async {
    if (_currentPosition == null) return;
    try {
      final nearbyPoints = await apiService.fetchNearbySupportPoints(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        query: query,
        limit: 20,
        sortBy: 'distance',
      );

      // Adicionar marcadores ao mapa para cada ponto de apoio
      setState(() {
        _markers = nearbyPoints['results'].map<Marker>((point) {
          return Marker(
            markerId: MarkerId(point['id']),
            position:
                LatLng(point['position']['lat'], point['position']['lng']),
            infoWindow: InfoWindow(
              title: point['title'],
              snippet: point['address'],
              onTap: () => _onMarkerTapped(point),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        }).toSet();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pontos de apoio: $e')),
      );
    }
  }

  // Função que será chamada quando o marcador for clicado
  void _onMarkerTapped(Map<String, dynamic> point) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(point['position']['lat'], point['position']['lng']),
        17.0,
      ),
    );
    _showBottomSheetDetails(point);
  }

  // Exibe o BottomSheet com os detalhes do ponto de apoio
  void _showBottomSheetDetails(Map<String, dynamic> point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point['title'],
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(point['address'], style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating:
                          double.tryParse(point['rating'].toString()) ?? 0.0,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 25.0,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(width: 8),
                    Text(
                        point['rating'] != null
                            ? '${point['rating']}'
                            : 'Sem avaliação',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horário:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point['opening_hours']?['status'] ??
                                'Status não disponível',
                            style: TextStyle(
                              fontSize: 16,
                              color: point['opening_hours']?['status'] ==
                                      'Aberto agora'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (point['opening_hours'] != null &&
                              point['opening_hours']['text'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  point['opening_hours']['text'].length,
                                  (index) {
                                return Text(
                                    point['opening_hours']['text'][index],
                                    style: TextStyle(fontSize: 14));
                              }),
                            )
                          else
                            Text('Horário não disponível',
                                style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (point['photos'] != null && point['photos'].isNotEmpty)
                  _buildPhotoCarousel(point['photos']),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openDirectionsInGoogleMaps(
                          point['position']['lat'], point['position']['lng']),
                      icon: Icon(Icons.directions),
                      label: Text('Obter Direção'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openStreetView(
                          point['position']['lat'], point['position']['lng']),
                      icon: Icon(Icons.streetview),
                      label: Text('Street View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCarousel(List photos) {
    return Container(
      height: 200,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(photo['url'], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  void _openDirectionsInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Não foi possível abrir o Google Maps');
    }
  }

  void _openStreetView(double lat, double lng) async {
    final url =
        'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Não foi possível abrir o Street View');
    }
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? LatLng(0, 0),
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                   mapToolbarEnabled: false,
                  onTap: (_) =>
                      setState(() => _isFilterVisible = !_isFilterVisible),
                ),
          if (_isFilterVisible)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _isFilterVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      label: Text("CRAS"),
                      selected: _selectedFilter == "CRAS",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "CRAS";
                        _loadSupportPoints(query: "CRAS");
                      }),
                    ),
                    SizedBox(width: 8),
                    FilterChip(
                      label: Text("Psiquiátricas"),
                      selected: _selectedFilter == "Clínicas Psiquiátricas",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "Clínicas Psiquiátricas";
                        _loadSupportPoints(query: "Clínicas Psiquiátricas");
                      }),
                    ),
                    SizedBox(width: 8),
                    FilterChip(
                      label: Text("Psicólogos"),
                      selected: _selectedFilter == "Clínicas psicológicas",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "Clínicas psicológicas";
                        _loadSupportPoints(query: "Clínicas psicológicas");
                      }),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _centerMap,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
