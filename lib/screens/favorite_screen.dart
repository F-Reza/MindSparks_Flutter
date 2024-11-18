import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteQuotes = [];  // Initialize as an empty list
  bool isLoading = true;  // Loading state

  @override
  void initState() {
    super.initState();
    _loadFavoriteQuotes();
  }

  // Load favorite quotes from SharedPreferences
  Future<void> _loadFavoriteQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> quotes = prefs.getStringList('favorite_quotes') ?? [];
    setState(() {
      favoriteQuotes = quotes;
      isLoading = false;  // Set loading to false after fetching data
    });
  }


  // Save favorite quotes to SharedPreferences
  Future<void> _saveFavoriteQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_quotes', favoriteQuotes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator while fetching data
          : favoriteQuotes.isEmpty
          ? const Center(child: Text('No favorite quotes added yet.', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),  // Add some space below the AppBar
                child: Text(
                  'Favorite Quotes',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF323346),
                  ),
                  textAlign: TextAlign.center,  // Ce
                  // nter the title
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 6,right: 6,bottom: 6,top: 6),
                  itemCount: favoriteQuotes.length,
                  itemBuilder: (context, index) {
                    bool isFavorite = favoriteQuotes.contains(favoriteQuotes.first);
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
                                text: favoriteQuotes[index],
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
                                favoriteQuotes.remove(favoriteQuotes.first);
                              } else {
                                favoriteQuotes.add(favoriteQuotes.first);
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
              ),
            ],
          ),
    );
  }
}
