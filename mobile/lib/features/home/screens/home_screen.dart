import 'package:flutter/material.dart';

import '../../listings/screens/map_screen.dart';
import '../widgets/kuik_bottom_nav.dart';
import 'accueil_screen.dart';
import 'my_listings_screen.dart';
import 'saved_listings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _goToTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          AccueilScreen(onSeeMap: () => _goToTab(1)),
          const MapScreen(),
          const MyListingsScreen(),
          const SavedListingsScreen(),
        ],
      ),
      bottomNavigationBar: KuikBottomNav(currentIndex: _tab, onTap: _goToTab),
    );
  }
}
