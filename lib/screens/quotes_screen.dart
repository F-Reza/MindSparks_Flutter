import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/quotes.dart';

class QuotesScreen extends StatefulWidget {
  final String category;

  // Constructor to receive category data
  const QuotesScreen({super.key, required this.category});

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  List<String> favoriteQuotes = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    _loadFavoriteQuotes();
  }

  // Load favorite quotes from SharedPreferences
  Future<void> _loadFavoriteQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuotes = prefs.getStringList('favorite_quotes') ?? [];
    });
  }

  // Save favorite quotes to SharedPreferences
  Future<void> _saveFavoriteQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_quotes', favoriteQuotes);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the list of all category quotes
    final List<CategoryQuote> categories = CategoryQuote.getAllCategoryQuotes();

    // Find the quotes for the selected category
    final CategoryQuote? selectedCategory = categories.firstWhere(
          (categoryQuote) => categoryQuote.categoryTitle == widget.category,
      orElse: () => CategoryQuote(categoryTitle: '', quotes: []),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Quotes',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF323346),
        foregroundColor: Colors.white,
      ),
      body: selectedCategory!.quotes.isEmpty
          ? const Center(
        child: Text(
          'No quotes available for this category.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedCategory.quotes.length,
            itemBuilder: (context, index) {
              bool isFavorite = favoriteQuotes.contains(selectedCategory.quotes[index]);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  title: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '“', // Opening quotation mark
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        TextSpan(
                          text: selectedCategory.quotes[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                          text: '”', // Closing quotation mark
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFavorite) {
                          favoriteQuotes.remove(selectedCategory.quotes[index]);
                        } else {
                          favoriteQuotes.add(selectedCategory.quotes[index]);
                        }
                      });
                      _saveFavoriteQuotes();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removed from favorites'
                                : 'Added to favorites',
                            style: const TextStyle(fontSize: 16),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: isFavorite ? Colors.redAccent : Colors.black54,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}
