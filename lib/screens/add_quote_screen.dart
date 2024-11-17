import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/quote.dart';
import 'category_screen.dart';

class AddQuoteScreen extends StatefulWidget {
  final Quote? quote;
  final int? id;

  const AddQuoteScreen({this.quote, super.key, this.id});

  @override
  _AddQuoteScreenState createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _quoteController = TextEditingController();
  //final _categoryController = TextEditingController();

  List<Quote> allQuotes = [];
  List<Category> categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String? selectedCategory;

  // Fetch reminders and categories from the database
  void _fetchData() async {
    final result = await DatabaseHelper.instance.queryAll();
    final categoriesData = await _dbHelper.getCategories();
    setState(() {
      allQuotes = result.map((e) => Quote.fromMap(e)).toList();
      categories = categoriesData;
      //selectedCategory = null;  // Reset the selected category
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    if (widget.quote != null) {
      _quoteController.text = widget.quote!.quote;
      selectedCategory = widget.quote!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF323346),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.quote == null ? "Add Quote" : "Edit Quote",
          style: const TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Show the confirmation dialog before proceeding with the delete operation
              bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Are you sure you want to delete \nthis Quote?"
                      ,style: TextStyle(fontSize: 18),),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);  // User pressed "Cancel"
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);  // User pressed "Delete"
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );

              // If the user confirms, delete the item
              if (confirmDelete == true) {
                await DatabaseHelper.instance.delete(widget.id!);
                Navigator.pop(context, true);  // Close the screen and pass "true" to indicate deletion
              }
            },
          )

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _quoteController,
              decoration: const InputDecoration(labelText: "Quote"),
            ),
            const SizedBox(height: 10),
            categories.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "No categories found. Please add a category.",
                    style: TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(),
                        ),
                      ).then((_) {
                        _fetchData();
                        });
                      },
                      child: const Text("Add Category"),
                      ),
                    ],
                  ),
                )
                : Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                value: selectedCategory,
                hint: Text("Select Category..."),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text("Select Category..."),
                  ),
                  ...categories.map((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.name),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_quoteController.text.isEmpty || selectedCategory!.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quote or Category can't be empty!")),
                  );
                  return;
                }
                if (widget.quote == null) {
                  final quote = Quote(
                    quote: _quoteController.text,
                    category: selectedCategory!,
                    dateTime: DateTime.now(),
                  );
                  await DatabaseHelper.instance.insert(quote.toMap());
                } else {
                  final updatedQuote = Quote(
                    id: widget.quote!.id,
                    quote: _quoteController.text,
                    category: selectedCategory!,
                    dateTime: widget.quote!.dateTime,
                  );
                  await DatabaseHelper.instance.update(updatedQuote.toMap());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quote Successfully Updated!")),
                  );
                }
                Navigator.pop(context, true);
              },
              child: Text(widget.quote == null ? "Add" : "Save"),
            ),
          ],
        ),
      ),
    );
  }
}
