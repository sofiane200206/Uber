import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future <void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  MapboxOptions.setAccessToken(dotenv.get('SECRET'));
   await Supabase.initialize(
    url: 'https://ptrpkvjypvzjvynhsqtc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0cnBrdmp5cHZ6anZ5bmhzcXRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNDI1MDUsImV4cCI6MjA1NTYxODUwNX0.geqhQj6sUGB08zUqNSPXraFue2aXuF1XC5OcGRciG7g',
   );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des bagarreurs',
      home: const HomeScreen(),
    );
  }
}
