import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo ; // Import pour charger l'image
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' ;



class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapWidget mapWidget;
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  @override
  void initState() {
    super.initState();

    // Paramètres de la caméra (centre sur Lyon)
    CameraOptions cameraOptions = CameraOptions(
      center: Point(coordinates: Position(4.8357, 45.7640)), // Coordonnées de Lyon
      zoom: 12,
      bearing: 0,
      pitch: 0,
    );

    mapWidget = MapWidget(
      cameraOptions: cameraOptions,
      onMapCreated: _onMapCreated, // Appelle la fonction une fois la carte créée
    );
  }

  /// Fonction appelée lorsque la carte est prête
  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Charger l'image de l'annotation depuis les assets
    final ByteData bytes = await rootBundle.load('assets/test.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Créer un point avec une icône personnalisée
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(4.8357, 45.7640)), // Coordonnées de Lyon
      image: imageData,
      iconSize: 0.1,
    );

    // Ajouter l'annotation sur la carte
    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte")),
      body: mapWidget,
    );
  }
}
