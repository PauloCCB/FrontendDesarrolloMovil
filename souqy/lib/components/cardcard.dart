import 'package:flutter/material.dart';

// Componente para cada tarjeta de auto
class Cardcar extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String condition;
  final String price;
  final VoidCallback? onImageTap;

  const Cardcar({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.condition,
    required this.price,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final pastelCard = const Color(0xFFF6F6FA);
    final pastelShadow = const Color(0xFFD1C4E9);
    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 110,
        width: double.infinity,
        errorBuilder:
            (_, __, ___) => Container(height: 110, color: Colors.grey[400]),
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        height: 110,
        width: double.infinity,
        errorBuilder:
            (_, __, ___) => Container(height: 110, color: Colors.grey[400]),
      );
    }
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pastelCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pastelShadow.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF5B5B5B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            condition,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Color(0xFF9A9A9A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF7B6CF6),
            ),
          ),
        ],
      ),
    );
  }
}
