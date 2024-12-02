import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/theme/theme.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final ApiService apiService = ApiService();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isFilterVisible = false;
  String _selectedFilter = "Todos";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: ScaledText(
            'Permissão de localização negada',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    _loadSupportPoints();
  }

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
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: ScaledText(
            'Erro ao carregar pontos de apoio: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
      );
    }
  }

  void _onMarkerTapped(Map<String, dynamic> point) {

     FocusScope.of(context).unfocus();

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(point['position']['lat'], point['position']['lng']),
        17.0,
      ),
    );
    _showBottomSheetDetails(point);
  }

  void _showBottomSheetDetails(Map<String, dynamic> point) {

    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(16.0.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(
                  point['title'],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 8.h),
                ScaledText(
                  point['address'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating:
                          double.tryParse(point['rating'].toString()) ?? 0.0,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: rateColor,
                      ),
                      itemCount: 5,
                      itemSize: 25.0.w,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(width: 8.w),
                    ScaledText(
                      point['rating'] != null
                          ? '${point['rating']}'
                          : 'Sem avaliação',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      'Horário:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaledText(
                            point['opening_hours']?['status'] ??
                                'Status não disponível',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: point['opening_hours']?['status'] ==
                                          'Aberto agora'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          if (point['opening_hours'] != null &&
                              point['opening_hours']['text'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  point['opening_hours']['text'].length,
                                  (index) {
                                return ScaledText(
                                  point['opening_hours']['text'][index],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                );
                              }),
                            )
                          else
                            ScaledText(
                              'Horário não disponível',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (point['photos'] != null && point['photos'].isNotEmpty)
                  _buildPhotoCarousel(point['photos']),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openDirectionsInGoogleMaps(
                          point['position']['lat'], point['position']['lng']),
                      icon: Icon(
                        Icons.directions,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: ScaledText(
                        'Obter Direção',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openStreetView(
                          point['position']['lat'], point['position']['lng']),
                      icon: Icon(
                        Icons.streetview,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: ScaledText(
                        'Street View',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
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
    return SizedBox(
      height: 200.h,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.0.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0.r),
              child: Image.network(photo['url'], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  void _openDirectionsInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showError('Não foi possível abrir o Google Maps');
    }
  }

  void _openStreetView(double lat, double lng) async {
    final url =
        'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showError('Não foi possível abrir o Street View');
    }
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: ScaledText(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
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
              top: 20.h,
              left: 20.w,
              right: 20.w,
              child: AnimatedOpacity(
                opacity: _isFilterVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      label: ScaledText(
                        "CRAS",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      selected: _selectedFilter == "CRAS",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "CRAS";
                        _loadSupportPoints(query: "CRAS");
                      }),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(width: 8.w),
                    FilterChip(
                      label: ScaledText(
                        "Psiquiátricas",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      selected: _selectedFilter == "Clínicas Psiquiátricas",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "Clínicas Psiquiátricas";
                        _loadSupportPoints(query: "Clínicas Psiquiátricas");
                      }),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(width: 8.w),
                    FilterChip(
                      label: ScaledText(
                        "Psicólogos",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      selected: _selectedFilter == "Clínicas psicológicas",
                      onSelected: (_) => setState(() {
                        _selectedFilter = "Clínicas psicológicas";
                        _loadSupportPoints(query: "Clínicas psicológicas");
                      }),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20.h,
            right: 20.w,
            child: FloatingActionButton(
              onPressed: _centerMap,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.my_location,
                size: 24.sp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
