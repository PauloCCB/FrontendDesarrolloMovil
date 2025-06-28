import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:souqy/components/cardcard.dart';
import 'package:souqy/screens/search.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List autos = [];
  bool loading = true;
  List<Map<String, dynamic>> recommendations = [];
  bool loadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    fetchAutos();
  }

  Future<void> fetchAutos() async {
    final response = await http.get(
      Uri.parse('https://auto-radar.ryodev.me/auto-scraper/find-by-filter'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        autos = data['autos'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      // Manejo de error
    }
  }

  Future<void> searchAutos({
    required String brand,
    required String model,
    String? minPrice,
    String? maxPrice,
    String? minYear,
  }) async {
    setState(() {
      loading = true;
      loadingRecommendations = true;
    });
    // Buscar recomendaciones
    fetchRecommendations(brand: brand, model: model);
    final Map<String, String> params = {'brand': brand, 'model': model};
    if (minPrice != null && minPrice.isNotEmpty) {
      params['min_price'] = minPrice;
    }
    if (maxPrice != null && maxPrice.isNotEmpty) {
      params['max_price'] = maxPrice;
    }
    if (minYear != null && minYear.isNotEmpty) {
      params['min_year'] = minYear;
    }
    final uri = Uri.parse(
      'https://auto-radar.ryodev.me/auto-scraper/find-by-filter',
    ).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        autos = data['autos'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al buscar autos.')));
    }
  }

  Future<void> fetchRecommendations({
    required String brand,
    required String model,
  }) async {
    setState(() {
      loadingRecommendations = true;
      recommendations = [];
    });
    final uri = Uri.parse(
      'https://modeloautos-production.up.railway.app/similar-cars-by-model',
    ).replace(queryParameters: {'marca': brand, 'modelo': model, 'count': '5'});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List recs = data['recommendations'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    final pastelBackground = const Color(0xFFF8EFFF);
    return Container(
      color: pastelBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Search(
              onSearch: ({
                required brand,
                required model,
                minPrice,
                maxPrice,
                minYear,
              }) {
                searchAutos(
                  brand: brand,
                  model: model,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  minYear: minYear,
                );
              },
            ),
            const SizedBox(height: 12),
            if (loadingRecommendations)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recommendations.isNotEmpty)
              _RecommendationsList(recommendations: recommendations),
            Expanded(
              child:
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        itemCount: autos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          final auto = autos[index];
                          return Cardcar(
                            imageUrl: auto['image_url'] ?? '',
                            title: auto['title'] ?? '',
                            condition:
                                auto['year'] != null
                                    ? 'Año: ${auto['year']}'
                                    : '',
                            price:
                                auto['price'] != null
                                    ? ' ${auto['price']}'
                                    : '',
                            onImageTap:
                                auto['url'] != null
                                    ? () => _showRedirectDialog(auto['url'])
                                    : null,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRedirectDialog(String url) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => _AnimatedRedirectDialog(
            onAccept: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
    if (result == true) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la URL.')),
        );
      }
    }
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
              final rec = recommendations[index];
              return Container(
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    if (rec['Transmisión'] != null)
                      Text(
                        '${rec['Transmisión']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
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
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _AnimatedRedirectDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  const _AnimatedRedirectDialog({
    required this.onAccept,
    required this.onCancel,
  });

  @override
  State<_AnimatedRedirectDialog> createState() =>
      _AnimatedRedirectDialogState();
}

class _AnimatedRedirectDialogState extends State<_AnimatedRedirectDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: const Color(0xFFF8EFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE6FA),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.open_in_new,
                  size: 36,
                  color: Color(0xFF7B6CF6),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '¿Ir a la página del carro?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B5B5B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Se abrirá una nueva ventana en tu navegador.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFF7B6CF6)),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onAccept,
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Color(0xFF7B6CF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
