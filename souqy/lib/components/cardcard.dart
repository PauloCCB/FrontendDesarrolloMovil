import 'package:flutter/material.dart';

// Componente para cada tarjeta de auto
class Cardcar extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String condition; // New o Used
  final String price;

  const Cardcar({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.condition,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del auto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) =>
                        Container(height: 110, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Título del auto
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 2),
          // Condición
          Text(
            condition,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Precio
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
