import 'package:flutter/material.dart';
import 'package:souqy/components/cardcard.dart';
import 'package:souqy/screens/search.dart';

class HomePageContent extends StatelessWidget {
  HomePageContent({super.key});

  final List<Map<String, String>> cars = const [
    {
      "imageUrl": "assets/images/audi.png",
      "title": "Audi Sports",
      "condition": "Used",
      "price": "\$ 85,000",
    },
    {
      "imageUrl": "assets/images/camaro.png",
      "title": "Camaro Sports",
      "condition": "Used",
      "price": "\$ 83,000",
    },
    {
      "imageUrl": "assets/images/mclaren.jpeg",
      "title": "McLaren Supercar",
      "condition": "New",
      "price": "\$ 120,000",
    },
    {
      "imageUrl": "assets/images/camaro.png",
      "title": "Camaro Sports",
      "condition": "New",
      "price": "\$ 80,000",
    },
    {
      "imageUrl": "assets/images/ferrari.jpeg",
      "title": "Ferrari Sports",
      "condition": "New",
      "price": "\$ 160,000",
    },
    {
      "imageUrl": "assets/images/bugatti.png",
      "title": "Bugatti Sports",
      "condition": "Used",
      "price": "\$ 140,000",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Search(),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: cars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final car = cars[index];
                return Cardcar(
                  imageUrl: car["imageUrl"] ?? "",
                  title: car["title"] ?? "",
                  condition: car["condition"] ?? "",
                  price: car["price"] ?? "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
