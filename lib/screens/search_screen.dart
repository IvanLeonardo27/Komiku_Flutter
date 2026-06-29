import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'comic_detail_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchProvider>();
    final home = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppTheme.creamLight,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cari Komik',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (v) {
                            context.read<SearchProvider>().query = v;
                            if (v.isEmpty) context.read<SearchProvider>().clearQuery();
                          },
                          onSubmitted: (_) => context.read<SearchProvider>().search(),
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan judul...',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.cancel, color: AppTheme.textLight),
                                    onPressed: () {
                                      _controller.clear();
                                      context.read<SearchProvider>().clearQuery();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.cardBackground,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: const BorderSide(color: AppTheme.divider)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: const BorderSide(color: AppTheme.divider)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: const BorderSide(color: AppTheme.primaryGreen)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.read<SearchProvider>().search(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: const Text('Cari', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Results
            Expanded(
              child: vm.isSearching
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : vm.results.isEmpty && vm.query.isNotEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: AppTheme.divider),
                              SizedBox(height: 8),
                              Text('Komik tidak ditemukan', style: TextStyle(color: AppTheme.textMedium)),
                              Text('Coba kata kunci lain', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.results.isEmpty ? home.featuredComics.length + home.popularComics.length : vm.results.length,
                          itemBuilder: (context, i) {
                            final comics = vm.results.isEmpty
                                ? [...home.featuredComics, ...home.popularComics]
                                : vm.results;
                            if (i == 0 && vm.results.isEmpty)
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Semua Komik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              );
                            final idx = vm.results.isEmpty ? i : i;
                            if (idx >= comics.length) return const SizedBox();
                            return ComicCardHorizontal(
                              comic: comics[idx],
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ComicDetailScreen(comic: comics[idx]),
                              )),
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