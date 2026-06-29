import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../services/network_service.dart';
import '../theme/app_theme.dart';

class ChapterReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final String comicTitle;
  const ChapterReaderScreen({super.key, required this.chapter, required this.comicTitle});

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  List<String> _pages = [];
  bool _isLoading = true;
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPages() async {
    if (widget.chapter.pages.isNotEmpty) {
      setState(() { _pages = widget.chapter.pages; _isLoading = false; });
      return;
    }
    try {
      final detail = await NetworkService.shared.getChapterDetail(widget.chapter.id);
      setState(() { _pages = detail.pages; _isLoading = false; });
    } catch (_) {
      setState(() { _pages = []; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(widget.comicTitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text(widget.chapter.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Text('${_currentPage + 1}/${_pages.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.lightGreen))
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, i) => CachedNetworkImage(
                        imageUrl: _pages[i],
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: AppTheme.lightGreen)),
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 48)),
                      ),
                    ),
            ),
            // Progress Bar
            LinearProgressIndicator(
              value: _pages.isEmpty ? 0 : (_currentPage + 1) / _pages.length,
              backgroundColor: Colors.white12,
              color: AppTheme.accentGreen,
              minHeight: 3,
            ),
          ],
        ),
      ),
    );
  }
}