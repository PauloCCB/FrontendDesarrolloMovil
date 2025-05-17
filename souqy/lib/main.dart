import 'package:flutter/material.dart';
import 'package:souqy/components/main_screens.dart';
import 'package:souqy/screens/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner:
          false, // Opcional, para quitar el banner debug
      home: MainScreen(), // Aquí lanzas el widget con navegación
    );
  }
}
