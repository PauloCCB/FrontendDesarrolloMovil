import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:souqy/components/similar_cars.dart';

class CameraUploadPage extends StatefulWidget {
  const CameraUploadPage({super.key});

  @override
  State<CameraUploadPage> createState() => _CameraUploadPageState();
}

class _CameraUploadPageState extends State<CameraUploadPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  Map<String, dynamic>? _carInfo;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pickAndSendImage();
  }

  Future<void> _pickAndSendImage() async {
    setState(() {
      _loading = true;
      _error = null;
      _carInfo = null;
      _selectedImageFile = null;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          _loading = false;
          _error = 'No se seleccionó ninguna imagen.';
        });
        return;
      }

      setState(() {
        _selectedImageFile = File(image.path);
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://206.189.237.170:8000/describe-car-image/'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _carInfo = jsonResponse;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Widget _buildCarInfo() {
    if (_carInfo == null) return const SizedBox();

    // Extraer solo los campos deseados (con fallback a '-')
    String brand = _carInfo!['brand'] ?? '-';
    String model = _carInfo!['model'] ?? '-';
    // El year es numérico, convertir a string o mostrar "-"
    String year =
        _carInfo!['year'] != null ? _carInfo!['year'].toString() : '-';
    String type = _carInfo!['type'] ?? '-';
    String colorName = _carInfo!['color_name'] ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marca: $brand', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Modelo: $model', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Año: $year', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Tipo: $type', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Color: $colorName', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimilarCars()),
              );
            },
            child: const Text('Buscar carro'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: const Text(
                        'Búsqueda de vehiculo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImageFile != null)
                      Image.file(_selectedImageFile!, height: 250),
                    const SizedBox(height: 24),
                    _buildCarInfo(),
                  ],
                ),
              ),
    );
  }
}
