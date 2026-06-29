import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'comic_detail_screen.dart';
import 'home_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeProvider>();
      if (vm.categories.isEmpty) vm.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Text('Semua Kategori',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            ),
            if (vm.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
                  ),
                  itemCount: vm.categories.length,
                  itemBuilder: (context, i) {
                    final cat = vm.categories[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CategoryComicListScreen(category: cat),
                      )),
                      child: _CategoryGridCard(category: cat),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  final KomikCategory category;
  const _CategoryGridCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.hexToColor(category.colorHex);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconFromName(category.iconName), color: color, size: 28),
                  const SizedBox(height: 2),
                  Text('${category.comicCount} komik', style: TextStyle(fontSize: 9, color: color.withOpacity(0.8))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(category.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  IconData _iconFromName(String name) {
    final map = {
      'face.smiling': Icons.sentiment_satisfied_alt,
      'bolt.fill': Icons.bolt,
      'moon.fill': Icons.nightlight_round,
      'heart.fill': Icons.favorite,
      'sparkles': Icons.auto_awesome,
    };
    return map[name] ?? Icons.category;
  }
}

class CategoryComicListScreen extends StatefulWidget {
  final KomikCategory category;
  const CategoryComicListScreen({super.key, required this.category});

  @override
  State<CategoryComicListScreen> createState() => _CategoryComicListScreenState();
}

class _CategoryComicListScreenState extends State<CategoryComicListScreen> {
  final _catProvider = CategoryProvider();

  @override
  void initState() {
    super.initState();
    _catProvider.loadComics(widget.category.name);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.hexToColor(widget.category.colorHex);
    return ChangeNotifierProvider.value(
      value: _catProvider,
      child: Consumer<CategoryProvider>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                // Custom NavBar
                Container(
                  color: AppTheme.creamLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(_iconFromName(widget.category.iconName), color: color, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.category.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const Spacer(),
                      Text('${vm.comicsInCategory.length} komik',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                if (vm.isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
                else if (vm.comicsInCategory.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books, size: 48, color: AppTheme.divider),
                          SizedBox(height: 8),
                          Text('Belum ada komik di kategori ini', style: TextStyle(color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.comicsInCategory.length,
                      itemBuilder: (context, i) => ComicCardHorizontal(
                        comic: vm.comicsInCategory[i],
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ComicDetailScreen(comic: vm.comicsInCategory[i]),
                        )),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFromName(String name) {
    final map = {
      'face.smiling': Icons.sentiment_satisfied_alt,
      'bolt.fill': Icons.bolt,
      'moon.fill': Icons.nightlight_round,
      'heart.fill': Icons.favorite,
      'sparkles': Icons.auto_awesome,
    };
    return map[name] ?? Icons.category;
  }
}