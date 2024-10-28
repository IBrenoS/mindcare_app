import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionPage extends StatefulWidget {
  @override
  _LocationPermissionPageState createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool isLocationGranted = false;
  bool isBackgroundLocationGranted = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  // Função para verificar permissões
  Future<void> checkPermissions() async {
    // Verificar permissão de localização normal
    PermissionStatus locationStatus = await Permission.location.status;
    setState(() {
      isLocationGranted = locationStatus == PermissionStatus.granted;
    });

    // Verificar permissão de localização em segundo plano
    PermissionStatus backgroundLocationStatus =
        await Permission.locationAlways.status;
    setState(() {
      isBackgroundLocationGranted =
          backgroundLocationStatus == PermissionStatus.granted;
    });
  }

  // Função para solicitar permissões
  Future<void> requestLocationPermission() async {
    // Solicitar permissão de localização normal
    PermissionStatus locationStatus = await Permission.location.request();
    if (locationStatus == PermissionStatus.granted) {
      setState(() {
        isLocationGranted = true;
      });

      // Agora que a permissão normal foi concedida, pedir permissão de segundo plano
      PermissionStatus backgroundLocationStatus =
          await Permission.locationAlways.request();
      if (backgroundLocationStatus == PermissionStatus.granted) {
        setState(() {
          isBackgroundLocationGranted = true;
        });
      } else {
        setState(() {
          isBackgroundLocationGranted = false;
        });
      }
    } else {
      setState(() {
        isLocationGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissões de Localização'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'Permissão de Localização: ${isLocationGranted ? "Concedida" : "Negada"}'),
            Text(
                'Permissão de Localização em Segundo Plano: ${isBackgroundLocationGranted ? "Concedida" : "Negada"}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: requestLocationPermission,
              child: Text('Solicitar Permissão de Localização'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LocationPermissionPage(),
  ));
}
