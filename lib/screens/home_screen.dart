import 'package:flutter/material.dart';
import 'package:mind_sparks/screens/quote_list.dart';

import 'favorite_screen.dart';
import 'my_quote_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Pages for navigation
  final List<Widget> _pages = [
    const QuoteList(),
    const FavoritesScreen(),
    const MyQuoteScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
      activeIcon: Icon(Icons.home_filled),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline_sharp),
      label: 'Favorites',
      activeIcon:Icon(Icons.favorite)
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.queue_outlined),
        label: 'My Quotes',
        activeIcon:Icon(Icons.queue_outlined)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF323346),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_with),
            const SizedBox(width: 5,),
            Text('MindSparks',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ],
        ),
        //centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_currentIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF323346), Color(0xFF323346)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          unselectedIconTheme: const IconThemeData(color: Colors.white54),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _navItems,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: Colors.transparent,
          elevation: 10,
        ),
      ),
    );
  }
}
