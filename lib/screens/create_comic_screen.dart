import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../services/network_service.dart';
import '../theme/app_theme.dart';

class DraftChapter {
  String title = '';
  List<String> pages = [''];
}

class CreateComicScreen extends StatefulWidget {
  const CreateComicScreen({super.key});

  @override
  State<CreateComicScreen> createState() => _CreateComicScreenState();
}

class _CreateComicScreenState extends State<CreateComicScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _posterController = TextEditingController();
  final List<DraftChapter> _draftChapters = [];
  bool _showSuccessBanner = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateComicProvider>();
    final homeVm = context.watch<HomeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: AppTheme.creamLight,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buat Komik', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                      const Text('Bagikan kreasi komikmu ke dunia', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster URL
                        _FormSection(title: 'URL Poster', icon: Icons.photo,
                          child: Column(
                            children: [
                              TextField(
                                controller: _posterController,
                                onChanged: (v) => setState(() {}),
                                decoration: _inputDecoration('https://contoh.com/poster.jpg'),
                              ),
                              if (_posterController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: _posterController.text,
                                      width: 130, height: 175, fit: BoxFit.cover,
                                      placeholder: (_, __) => const SizedBox(width: 130, height: 175, child: Center(child: CircularProgressIndicator())),
                                      errorWidget: (_, __, ___) => const SizedBox(),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        _FormSection(title: 'Judul Komik', icon: Icons.title,
                          child: TextField(controller: _titleController, decoration: _inputDecoration('Masukkan judul komik...')),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        _FormSection(title: 'Deskripsi', icon: Icons.description,
                          child: TextField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: _inputDecoration('Ceritakan sedikit tentang komikmu...'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Categories
                        _FormSection(title: 'Kategori', icon: Icons.tag, subtitle: 'Pilih minimal 1',
                          child: homeVm.isLoading
                              ? const CircularProgressIndicator(color: AppTheme.primaryGreen)
                              : Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: homeVm.categories.map((cat) {
                                    final isSelected = vm.selectedCategories.contains(cat.name);
                                    return GestureDetector(
                                      onTap: () => vm.toggleCategory(cat.name),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primaryGreen : AppTheme.surfaceGreen,
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(color: isSelected ? Colors.transparent : AppTheme.accentGreen.withOpacity(0.5)),
                                        ),
                                        child: Text(cat.name, style: TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : AppTheme.primaryGreen,
                                        )),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Chapters
                        _FormSection(
                          title: 'Chapter', icon: Icons.menu_book,
                          subtitle: '${_draftChapters.length} chapter',
                          child: Column(
                            children: [
                              ..._draftChapters.asMap().entries.map((entry) {
                                final i = entry.key;
                                final chapter = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.book_outlined, color: AppTheme.accentGreen, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Chapter ${i + 1}', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                                            Text(chapter.title.isEmpty ? 'Belum ada judul' : chapter.title,
                                                style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                                            Text('${chapter.pages.where((p) => p.isNotEmpty).length} halaman',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppTheme.accentGreen, size: 20),
                                        onPressed: () => _showChapterSheet(i),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: AppTheme.error, size: 20),
                                        onPressed: () => setState(() => _draftChapters.removeAt(i)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _draftChapters.add(DraftChapter()));
                                  _showChapterSheet(_draftChapters.length - 1);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceGreen,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.accentGreen.withOpacity(0.5)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                                      SizedBox(width: 8),
                                      Text('Tambah Chapter', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                                const SizedBox(width: 8),
                                Text(vm.errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton.icon(
                            onPressed: vm.isPublishing ? null : () => _publish(auth, vm),
                            icon: vm.isPublishing
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.upload),
                            label: const Text('Publikasikan Komik'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Success Banner
            if (_showSuccessBanner)
              Positioned(
                top: 16, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.secondaryGreen, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Komik berhasil dipublikasikan!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _publish(AuthProvider auth, CreateComicProvider vm) async {
    vm.title = _titleController.text;
    vm.description = _descController.text;
    vm.posterURL = _posterController.text;

    final comicId = await vm.publish(auth.currentUser?.id ?? '');
    if (comicId != null) {
      await _uploadChapters(comicId);
      setState(() => _showSuccessBanner = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSuccessBanner = false);
      });
      _titleController.clear();
      _descController.clear();
      _posterController.clear();
      setState(() => _draftChapters.clear());
    }
  }

  Future<void> _uploadChapters(int comicId) async {
    for (int i = 0; i < _draftChapters.length; i++) {
      final chapter = _draftChapters[i];
      if (chapter.title.isEmpty) continue;
      final chapterId = await NetworkService.shared.createChapter(comicId, chapter.title, i + 1);
      if (chapterId != null) {
        final validPages = chapter.pages.where((p) => p.isNotEmpty).toList();
        for (int j = 0; j < validPages.length; j++) {
          await NetworkService.shared.addChapterPage(chapterId, j + 1, validPages[j]);
        }
      }
    }
  }

  void _showChapterSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ChapterSheet(
        chapter: _draftChapters[index],
        onDone: () => setState(() {}),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppTheme.creamLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryGreen)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _ChapterSheet extends StatefulWidget {
  final DraftChapter chapter;
  final VoidCallback onDone;
  const _ChapterSheet({required this.chapter, required this.onDone});

  @override
  State<_ChapterSheet> createState() => _ChapterSheetState();
}

class _ChapterSheetState extends State<_ChapterSheet> {
  late TextEditingController _titleController;
  late List<TextEditingController> _pageControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapter.title);
    _pageControllers = widget.chapter.pages.map((p) => TextEditingController(text: p)).toList();
  }

  void _save() {
    widget.chapter.title = _titleController.text;
    widget.chapter.pages = _pageControllers.map((c) => c.text).toList();
    widget.onDone();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Buat Chapter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const Spacer(),
                TextButton(onPressed: _save, child: const Text('Selesai', style: TextStyle(color: AppTheme.primaryGreen))),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppTheme.textMedium))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: Petualangan Dimulai',
                labelText: 'Judul Chapter',
                filled: true, fillColor: AppTheme.creamLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Halaman (URL Gambar)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pageControllers.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 20, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppTheme.textLight))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _pageControllers[i],
                          decoration: InputDecoration(
                            hintText: 'https://...',
                            prefixIcon: const Icon(Icons.link, size: 16, color: AppTheme.textLight),
                            filled: true, fillColor: AppTheme.creamLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: AppTheme.error, size: 20),
                        onPressed: _pageControllers.length > 1
                            ? () => setState(() => _pageControllers.removeAt(i))
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _pageControllers.add(TextEditingController())),
              icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
              label: const Text('Tambah Halaman', style: TextStyle(color: AppTheme.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;
  const _FormSection({required this.title, required this.icon, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.accentGreen),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            if (subtitle != null) ...[
              const Text(' • ', style: TextStyle(color: AppTheme.textLight)),
              Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}