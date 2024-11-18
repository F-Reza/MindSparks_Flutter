import 'package:flutter/material.dart';
import 'quotes_screen.dart'; // Import the QuotesPage

class QuoteList extends StatelessWidget {
  const QuoteList({super.key});

  final List<Map<String, String>> categories = const [
    {'title': 'Inspiration', 'image': 'images/motivation.png'},
    {'title': 'Positive', 'image': 'images/life.png'},
    {'title': 'Success', 'image': 'images/success.png'},
    {'title': 'Happiness', 'image': 'images/happiness1.png'},
    {'title': 'Famous', 'image': 'images/famous2.png'},
    {'title': 'Wisdom', 'image': 'images/wisdom.png'},
    {'title': 'Life', 'image': 'images/life.png'},
    {'title': 'Family', 'image': 'images/family.png'},
    {'title': 'Friendship', 'image': 'images/friends.png'},
    {'title': 'Love', 'image': 'images/love1.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 8 / 6,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuotesScreen(category: category['title']!),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Image.asset(
                              category['image']!,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            category['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF323346),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 25,
                      top: 2,
                      child: Image.asset('images/queue.png',color: Colors.white,height: 20,),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
