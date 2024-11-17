import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/quote.dart';
import 'add_quote_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Quote>> quotes;
  List<Quote> allQuotes = [];
  String searchQuery = '';

  List<Category> categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _refreshQuotes();
  }

  // Fetch reminders and categories from the database
  void _fetchData() async {
    final result = await DatabaseHelper.instance.queryAll();
    final categoriesData = await _dbHelper.getCategories();
    setState(() {
      allQuotes = result.map((e) => Quote.fromMap(e)).toList();
      categories = categoriesData;
      selectedCategory = null;  // Reset the selected category
    });
  }

  Future<List<Quote>> fetchQuotes() async {
    final result = await DatabaseHelper.instance.queryAll();
    allQuotes = result.map((e) => Quote.fromMap(e)).toList();
    return allQuotes;
  }

  void _refreshQuotes() {
    setState(() {
      quotes = fetchQuotes();
    });
  }

  Quote getRandomQuote() {
    return allQuotes.isNotEmpty
        ? allQuotes[DateTime.now().millisecondsSinceEpoch % allQuotes.length]
        : Quote(quote: "No quotes available", category: "Unknown",dateTime: DateTime.now());
  }

  void shareQuote(String quote) {
    Share.share(quote);
  }

  List<Quote> filterQuotes() {
    if (searchQuery.isEmpty) {
      return allQuotes;
    } else {
      return allQuotes.where((quote) {
        return quote.quote.toLowerCase().contains(searchQuery.toLowerCase()) ||
            quote.category.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF323346),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('MindSparks',style: TextStyle(color: Colors.white),),
        actions: [
          if(allQuotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: () {
                Quote randomQuote = getRandomQuote();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Random Quote"),
                        const SizedBox(width: 8,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                if (randomQuote.quote.isNotEmpty) {
                                  Clipboard.setData(ClipboardData(text: randomQuote.quote));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Copied to clipboard!")),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                shareQuote(randomQuote.quote);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    content: Text(randomQuote.quote),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              ).then((_) {
                // After coming back from CategoryScreen, refresh categories
                _fetchData();
              });
            },
          ),
          /*IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuoteSearchDelegate(
                  allQuotes: allQuotes,
                  onSearchQueryChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
              );
            },
          ),*/
        ],
      ),
      body: FutureBuilder<List<Quote>>(
        future: quotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No quotes available"));
          } else {
            List<Quote> filteredQuotes = filterQuotes();
            return ListView.builder(
              itemCount: filteredQuotes.length,
              itemBuilder: (context, index) {
                final quote = filteredQuotes[index];
                return Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text(quote.quote),
                    subtitle: Text(quote.category,style: const TextStyle(color: Colors.blue),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            shareQuote(quote.quote);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            if (quote.quote.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: quote.quote));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Copied to clipboard!")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      final bool? isUpdated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddQuoteScreen(id: quote.id!,quote: quote),
                        ),
                      );
                      if (isUpdated == true) {
                        _refreshQuotes();
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xFF323346),
            onPressed: () async {
              final bool? isAdded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddQuoteScreen()),
              );
              if (isAdded == true) {
                _refreshQuotes();
              }
            },
            child: const Icon(Icons.add,color: Colors.white,),
          ),
          const SizedBox(height: 10),
          /*FloatingActionButton(
            onPressed: () {
              Quote randomQuote = getRandomQuote();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Random Quote"),
                      const SizedBox(width: 8,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              if (randomQuote.quote.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: randomQuote.quote));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Copied to clipboard!")),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              shareQuote(randomQuote.quote);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  content: Text(randomQuote.quote),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.shuffle,color: Colors.white,),
          ),*/
        ],
      ),
    );
  }
}

class QuoteSearchDelegate extends SearchDelegate {
  final List<Quote> allQuotes;
  final ValueChanged<String> onSearchQueryChanged;

  QuoteSearchDelegate({
    required this.allQuotes,
    required this.onSearchQueryChanged,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredResults = allQuotes.where((quote) {
      return quote.quote.toLowerCase().contains(query.toLowerCase()) ||
          quote.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final quote = filteredResults[index];
        return ListTile(
          title: Text(quote.quote),
          subtitle: Text(quote.category),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredSuggestions = allQuotes.where((quote) {
      return quote.quote.toLowerCase().contains(query.toLowerCase()) ||
          quote.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final quote = filteredSuggestions[index];
        return ListTile(
          title: Text(quote.quote),
          subtitle: Text(quote.category),
        );
      },
    );
  }
}
