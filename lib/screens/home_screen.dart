import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'comic_detail_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            : vm.errorMessage != null
                ? _buildError(vm)
                : RefreshIndicator(
                    color: AppTheme.primaryGreen,
                    onRefresh: () => vm.loadData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(auth),
                          const SizedBox(height: 16),
                          _buildFeaturedSection(vm),
                          const SizedBox(height: 16),
                          _buildCategoriesSection(vm),
                          const SizedBox(height: 16),
                          _buildPopularSection(vm),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildError(HomeProvider vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(vm.errorMessage!, style: const TextStyle(color: AppTheme.textMedium)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: vm.loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selamat datang,', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
              Text(auth.currentUser?.username ?? 'Pembaca',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.surfaceGreen,
            child: Text(
              (auth.currentUser?.username.substring(0, 1) ?? 'K').toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(HomeProvider vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unggulan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Text('Paling banyak dibaca', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.featuredComics.length,
            itemBuilder: (context, i) => _FeaturedComicCard(
              comic: vm.featuredComics[i],
              onTap: () => _openComic(context, vm.featuredComics[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(HomeProvider vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.categories.length,
            itemBuilder: (context, i) {
              final cat = vm.categories[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CategoryComicListScreen(category: cat),
                )),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.hexToColor(cat.colorHex).withOpacity(0.15),
                        child: Icon(_iconFromName(cat.iconName), color: AppTheme.hexToColor(cat.colorHex), size: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(cat.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${cat.comicCount}', style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSection(HomeProvider vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Populer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Text('Rating tertinggi', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.popularComics.length,
          itemBuilder: (context, i) => ComicCardHorizontal(
            comic: vm.popularComics[i],
            onTap: () => _openComic(context, vm.popularComics[i]),
          ),
        ),
      ],
    );
  }

  void _openComic(BuildContext context, Comic comic) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ComicDetailScreen(comic: comic),
    )).then((_) => context.read<HomeProvider>().loadData());
  }

  IconData _iconFromName(String name) {
    final map = {
      'face.smiling': Icons.sentiment_satisfied_alt,
      'bolt.fill': Icons.bolt,
      'moon.fill': Icons.nightlight_round,
      'heart.fill': Icons.favorite,
      'sparkles': Icons.auto_awesome,
      'books.vertical.fill': Icons.menu_book,
    };
    return map[name] ?? Icons.category;
  }
}

class _FeaturedComicCard extends StatelessWidget {
  final Comic comic;
  final VoidCallback onTap;
  const _FeaturedComicCard({required this.comic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: comic.posterURL, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.surfaceGreen),
                errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceGreen, child: const Icon(Icons.book, color: AppTheme.lightGreen, size: 40)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppTheme.primaryGreen.withOpacity(0.85)],
                  ),
                ),
              ),
              Positioned(
                left: 14, right: 14, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comic.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(comic.averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(width: 8),
                        if (comic.categories.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                            child: Text(comic.categories.first, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComicCardHorizontal extends StatelessWidget {
  final Comic comic;
  final VoidCallback onTap;
  const ComicCardHorizontal({super.key, required this.comic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: comic.posterURL, width: 70, height: 95, fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 70, height: 95, color: AppTheme.surfaceGreen),
                errorWidget: (_, __, ___) => Container(width: 70, height: 95, color: AppTheme.surfaceGreen, child: const Icon(Icons.book, color: AppTheme.lightGreen)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: comic.categories.take(2).map((cat) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.surfaceGreen, borderRadius: BorderRadius.circular(100)),
                      child: Text(cat, style: const TextStyle(fontSize: 10, color: AppTheme.primaryGreen)),
                    )).toList(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      Text(' ${comic.averageRating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
                      const SizedBox(width: 8),
                      const Icon(Icons.visibility, color: AppTheme.accentGreen, size: 12),
                      Text(' ${_formatCount(comic.totalViews)}', style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chat_bubble, color: AppTheme.secondaryGreen, size: 12),
                      Text(' ${comic.totalComments}', style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${comic.chapterCount} Chapter', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) => count >= 1000 ? '${count ~/ 1000}K' : '$count';
}