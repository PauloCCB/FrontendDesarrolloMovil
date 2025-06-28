import 'package:flutter/material.dart';
import 'package:souqy/components/cardcard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SimilarCars extends StatefulWidget {
  final String brand;
  final String model;
  const SimilarCars({Key? key, required this.brand, required this.model})
    : super(key: key);

  @override
  State<SimilarCars> createState() => _SimilarCarsState();
}

class _SimilarCarsState extends State<SimilarCars> {
  List<Map<String, dynamic>> recommendations = [];
  List<Map<String, dynamic>> similarCars = [];
  bool loadingRecommendations = false;
  bool loadingCars = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
    fetchSimilarCars();
  }

  Future<void> fetchRecommendations() async {
    setState(() {
      loadingRecommendations = true;
    });
    final uri = Uri.parse(
      'https://modeloautos-production.up.railway.app/similar-cars-by-model',
    ).replace(
      queryParameters: {
        'marca': widget.brand,
        'modelo': widget.model,
        'count': '5',
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List recs =
          (data['recommendations'] ?? [])
              .map(
                (rec) => {
                  'Marca': rec['Marca'],
                  'Modelo': rec['Modelo'],
                  'Año': rec['Año'],
                  'Precio': rec['Precio'],
                  'Combustible': rec['Combustible'],
                  'Transmisión': rec['Transmisión'],
                  'Kilometraje': rec['Kilometraje'],
                },
              )
              .toList();
      setState(() {
        recommendations = recs.cast<Map<String, dynamic>>();
        loadingRecommendations = false;
      });
    } else {
      setState(() {
        recommendations = [];
        loadingRecommendations = false;
      });
    }
  }

  Future<void> fetchSimilarCars() async {
    setState(() {
      loadingCars = true;
    });
    final uri = Uri.parse(
      'https://auto-radar.ryodev.me/auto-scraper/find-by-filter',
    ).replace(queryParameters: {'brand': widget.brand, 'model': widget.model});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List cars = data['autos'] ?? [];
      setState(() {
        similarCars = cars.cast<Map<String, dynamic>>();
        loadingCars = false;
      });
    } else {
      setState(() {
        similarCars = [];
        loadingCars = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Cars'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadingRecommendations)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recommendations.isNotEmpty)
              _RecommendationsList(recommendations: recommendations),
            const SizedBox(height: 10),
            Expanded(
              child:
                  loadingCars
                      ? const Center(child: CircularProgressIndicator())
                      : similarCars.isEmpty
                      ? const Center(
                        child: Text('No se encontraron autos similares.'),
                      )
                      : GridView.builder(
                        itemCount: similarCars.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemBuilder: (context, index) {
                          final car = similarCars[index];
                          return Cardcar(
                            imageUrl: car["image_url"] ?? "",
                            title: car["title"] ?? "",
                            condition:
                                car["year"] != null
                                    ? 'Año: ${car["year"]}'
                                    : '',
                            price:
                                car["price"] != null ? ' ${car["price"]}' : '',
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsList extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  const _RecommendationsList({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Recomendaciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _AnimatedRecommendationCard(rec: recommendations[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _AnimatedRecommendationCard extends StatefulWidget {
  final Map<String, dynamic> rec;
  const _AnimatedRecommendationCard({required this.rec});

  @override
  State<_AnimatedRecommendationCard> createState() =>
      _AnimatedRecommendationCardState();
}

class _AnimatedRecommendationCardState
    extends State<_AnimatedRecommendationCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.96;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTap() {
    final rec = widget.rec;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seleccionado: ${rec['Marca']} ${rec['Modelo']} (${rec['Año']})',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    // Aquí puedes navegar o mostrar más detalles si lo deseas
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.rec;
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 210,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.07),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${rec['Marca']} ${rec['Modelo']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${rec['Año']}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  if (rec['Kilometraje'] != null)
                    Text(
                      '${rec['Kilometraje'].toString().replaceAll('.0', '')} km',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              if (rec['Combustible'] != null)
                Text(
                  '${rec['Combustible']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              if (rec['Transmisión'] != null)
                Text(
                  '${rec['Transmisión']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              const Spacer(),
              Text(
                rec['Precio'] != null
                    ? '\u0024${rec['Precio'].toString().replaceAll('.0', '')}'
                    : '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF21B573),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
