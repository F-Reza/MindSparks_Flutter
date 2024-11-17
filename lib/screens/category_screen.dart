import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category.dart'; // Assuming you have a Category model

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch categories from the database
  void _fetchCategories() async {
    final categoriesData = await _dbHelper.getCategories();
    setState(() {
      categories = categoriesData; // Store fetched data
    });
  }

  // Method to add a new category
  void _addCategory() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter category name'),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _dbHelper.insertCategory(Category(name: value)); // Add category to DB
                _fetchCategories(); // Refresh the category list
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if(controller.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Category field can't be empty!")),
                  );
                } else {
                  await _dbHelper.insertCategory(Category(name: controller.text)); // Save the new category
                  _fetchCategories(); // Refresh category list
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to edit a category
  void _editCategory(int index) {
    TextEditingController controller = TextEditingController(text: categories[index].name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Edit category name'),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                // Update category in DB
                _dbHelper.updateCategory(Category(id: categories[index].id, name: value));
                _fetchCategories(); // Refresh category list
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if(controller.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Category field can't be empty!")),
                  );
                }else  {
                  await _dbHelper.updateCategory(
                      Category(id: categories[index].id, name: controller.text),
                  ); // Save the edited category
                  _fetchCategories(); // Refresh category list
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a category from the DB
  void _deleteCategory111(int index) async {
    final categoryId = categories[index].id;
    if (categoryId != null) {
      await _dbHelper.deleteCategory(categoryId); // Ensure id is non-null
      _fetchCategories(); // Refresh the category list
    } else {
      // Handle case when the id is null (if necessary)
      print('Category ID is null');
    }
  }

  // Method to delete a category from the DB
  void _deleteCategory(int index) async {
    final categoryId = categories[index].id;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () async {
                if (categoryId != null) {
                  await _dbHelper.deleteCategory(categoryId); // Ensure id is non-null
                  _fetchCategories(); // Refresh the category list
                } else {
                  print('Category ID is null');
                }
                setState(() {
                  categories.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF323346),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Manage Categories',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory, // Open the add category dialog
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No categories added yet.'))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(categories[index].name),
              trailing: Wrap(
                spacing: 12, // space between icons
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editCategory(index), // Edit category
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCategory(index), // Delete category
                  ),
                ],
              ),
              //onTap: () => _editCategory(index), // Edit category when tapped
            ),
          );
        },
      ),
    );
  }
}
