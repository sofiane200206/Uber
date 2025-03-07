import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fighter.dart';
import 'package:flutter/services.dart';

class DetailScreen extends StatefulWidget {
  final Fighter fighter;

  const DetailScreen({super.key, required this.fighter});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  double userDistance = -1;

  @override
  void initState() {
    super.initState();
    _getUserDistance();
  }

  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    final annotationManager = await map.annotations.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager = annotationManager;
    });
    _addFighterMarker();
  }

  void _addFighterMarker() async {
    if (pointAnnotationManager == null || mapboxMap == null) return;

    try {
      // Charger l’image depuis les assets
      final ByteData bytes = await rootBundle.load('assets/test.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      // Créer l'annotation avec l'image
      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
        image: imageData,
        textField: widget.fighter.name, // Image chargée en mémoire
        iconSize: 0.125,
        textOffset: [0, 2], // Ajuste la taille si nécessaire
      );

      // Ajouter l'annotation
      await pointAnnotationManager!.create(pointAnnotationOptions);

      // Centrer la carte sur l'annotation
      mapboxMap!.setCamera(CameraOptions(
        center: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
        zoom: 12,
      ));
    } catch (e) {
      print("Erreur lors du chargement de l'image : $e");
    }
  }

  Future<void> _getUserDistance() async {
    double distance = await calculateDistance(widget.fighter);
    if (mounted) {
      setState(() {
        userDistance = distance;
      });
    }
  }

  Future<double> calculateDistance(Fighter fighter) async {
    try {
      gl.Position position = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.high,
      );
      double distanceMeters = gl.Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        fighter.latitude,
        fighter.longitude,
      );
      return distanceMeters / 1000;
    } catch (e) {
      print("Erreur distance: $e");
      return -1;
    }
  }

  Future<void> _reserveFighter() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      // Si l'utilisateur n'est pas connecté, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour réserver un combattant")),
      );
      return;
    }

    try {
      // Ajouter la réservation dans la base de données
      final response = await Supabase.instance.client.from('reservations').insert({
        'user_id': userId,
        'fighter_id': widget.fighter.id,
      }).select().single();;

      

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Combattant réservé avec succès !")),
      );
    } catch (e) {
      // Affichage de l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la réservation : $e")),
      );
    }
  }

  Future<void> _deleteFighter() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('Fighters')
          .delete()
          .eq('id', widget.fighter.id)
          .select()
          .single(); // Remplacer execute() par select() et single()

      // Vérification si l'élément a bien été supprimé
      if (response == null) {
        throw Exception("Aucun combattant trouvé avec cet ID.");
      }

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Combattant supprimé avec succès !")),
      );
      Navigator.pop(context); // Retour à l'écran précédent

    } catch (e) {
      // Affichage de l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fighter.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(widget.fighter.image),
                ),
                const SizedBox(height: 20),
                Text(widget.fighter.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Distance : ${userDistance == -1 ? 'Calcul en cours...' : '${userDistance.toStringAsFixed(2)} km'}", 
                     style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Text("Poids: ${widget.fighter.poids} kg", style: const TextStyle(fontSize: 16)),
                Text("Taille: ${widget.fighter.taille} cm", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text("Description: ${widget.fighter.description}", style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmer la suppression"),
                          content: const Text("Es-tu sûr de vouloir supprimer ce combattant ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Supprimer"),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      _deleteFighter();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                ),
                // Ajouter ici le bouton "Réserver"
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool confirmReservation = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmer la réservation"),
                          content: const Text("Es-tu sûr de vouloir réserver ce combattant ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Réserver"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmReservation == true) {
                      // Appel de la fonction de réservation
                      await _reserveFighter();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Réserver", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: MapWidget(
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
