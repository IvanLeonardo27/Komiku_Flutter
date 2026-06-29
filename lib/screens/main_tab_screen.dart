import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'create_comic_screen.dart';
import 'profile_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedTab = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    SearchScreen(),
    CreateComicScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        backgroundColor: AppTheme.creamLight,
        indicatorColor: AppTheme.surfaceGreen,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppTheme.primaryGreen), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view, color: AppTheme.primaryGreen), label: 'Kategori'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search, color: AppTheme.primaryGreen), label: 'Cari'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: AppTheme.primaryGreen), label: 'Buat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen), label: 'Profil'),
        ],
      ),
    );
  }
}