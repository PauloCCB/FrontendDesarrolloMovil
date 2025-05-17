import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _HomePageState();
}

class _HomePageState extends State<Search> {
  final TextEditingController _controller = TextEditingController();

  void _onSearchSubmitted(String value) {
    // Aquí puedes manejar el valor que escribió el usuario y presionó Enter
    print('Buscar texto: $value');
    // Por ejemplo, llamar a un método para filtrar resultados o hacer la búsqueda
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
        right: 16,
        left: 16,
      ), // margen general
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Buscar',
                        border:
                            InputBorder.none, // Sin borde para que quede limpio
                      ),
                      onSubmitted: _onSearchSubmitted,
                      textInputAction:
                          TextInputAction
                              .search, // Muestra botón buscar en teclado
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
