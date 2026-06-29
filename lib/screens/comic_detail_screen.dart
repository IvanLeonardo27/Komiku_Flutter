import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'chapter_reader_screen.dart';

class ComicDetailScreen extends StatefulWidget {
  final Comic comic;
  const ComicDetailScreen({super.key, required this.comic});

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late ComicDetailProvider _vm;
  ComicComment? _replyingTo;
  final _replyController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = ComicDetailProvider(widget.comic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      _vm.loadChapters();
      _vm.loadComments();
      _vm.addView();
      _vm.refreshComic();
      _vm.loadUserRating(userId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ComicDetailProvider>(
        builder: (context, vm, _) {
          final auth = context.watch<AuthProvider>();
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroPoster(vm.comic),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection(vm),
                            const Divider(height: 32),
                            _buildRatingSection(vm, auth),
                            const Divider(height: 32),
                            _buildChaptersSection(vm),
                            const Divider(height: 32),
                            _buildCommentsSection(vm, auth),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroPoster(Comic comic) {
    return SizedBox(
      height: 280, width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: comic.posterURL, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppTheme.surfaceGreen),
            errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceGreen, child: const Icon(Icons.book, size: 60, color: AppTheme.lightGreen)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppTheme.background],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ComicDetailProvider vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(vm.comic.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 4),
        Text('oleh ${vm.comic.authorUsername}', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: vm.comic.categories.map((cat) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.surfaceGreen, borderRadius: BorderRadius.circular(100)),
            child: Text(cat, style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen)),
          )).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatBadge(icon: Icons.star, value: '${vm.comic.averageRating.toStringAsFixed(1)} (${vm.comic.totalRatings})', color: AppTheme.starYellow),
            const SizedBox(width: 12),
            _StatBadge(icon: Icons.visibility, value: '${vm.comic.totalViews}', color: AppTheme.accentGreen),
            const SizedBox(width: 12),
            _StatBadge(icon: Icons.chat_bubble, value: '${vm.comic.totalComments}', color: AppTheme.secondaryGreen),
            const SizedBox(width: 12),
            _StatBadge(icon: Icons.book, value: '${vm.chapters.length} Ch', color: AppTheme.primaryGreen),
          ],
        ),
        if (vm.comic.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(vm.comic.description, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5)),
        ],
      ],
    );
  }

  Widget _buildRatingSection(ComicDetailProvider vm, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Beri Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(5, (i) => Icon(
                i < vm.userRating ? Icons.star : Icons.star_border,
                color: AppTheme.starYellow, size: 28,
              )),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showRatingSheet(context, vm, auth),
              icon: Icon(vm.userRating > 0 ? Icons.star : Icons.star_border, size: 14),
              label: Text(vm.userRating > 0 ? 'Ubah Rating' : 'Nilai Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChaptersSection(ComicDetailProvider vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daftar Chapter', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text('${vm.chapters.length} chapter tersedia', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        if (vm.isLoadingChapters)
          const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.chapters.length,
            itemBuilder: (context, i) {
              final chapter = vm.chapters[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChapterReaderScreen(chapter: chapter, comicTitle: vm.comic.title),
                )),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppTheme.surfaceGreen, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text('${chapter.number}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                            Text('${chapter.uploadedAt.day}/${chapter.uploadedAt.month}/${chapter.uploadedAt.year}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textLight),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommentsSection(ComicDetailProvider vm, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Komentar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text('${vm.comic.totalComments} komentar', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
        const SizedBox(height: 12),
        // Reply indicator
        if (_replyingTo != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.surfaceGreen, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.reply, color: AppTheme.accentGreen, size: 14),
                const SizedBox(width: 6),
                Text('Membalas ${_replyingTo!.username}', style: const TextStyle(fontSize: 12, color: AppTheme.accentGreen)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() { _replyingTo = null; _replyController.clear(); }),
                  child: const Icon(Icons.cancel, color: AppTheme.textLight, size: 18),
                ),
              ],
            ),
          ),
        // Input
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceGreen,
              child: Text(
                (auth.currentUser?.username.substring(0, 1) ?? '?').toUpperCase(),
                style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _replyingTo != null ? _replyController : _commentController,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: _replyingTo != null ? 'Tulis balasan...' : 'Tulis komentar...',
                  filled: true,
                  fillColor: AppTheme.creamLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: vm.isSubmittingComment ? null : () async {
              final userId = auth.currentUser?.id ?? '';
              final username = auth.currentUser?.username ?? 'Anonim';
              if (_replyingTo != null) {
                await vm.submitReply(_replyingTo!.id, userId, username, _replyController.text);
                setState(() { _replyingTo = null; _replyController.clear(); });
              } else {
                vm.newComment = _commentController.text;
                await vm.submitComment(userId, username);
                _commentController.clear();
              }
            },
            icon: vm.isSubmittingComment
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, size: 14),
            label: Text(_replyingTo != null ? 'Kirim Balasan' : 'Kirim Komentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (vm.isLoadingComments)
          const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.comments.length,
            itemBuilder: (context, i) => _CommentCard(
              comment: vm.comments[i],
              currentUserId: auth.currentUser?.id ?? '',
              authorId: vm.comic.authorId,
              onReply: (target) {
                final parent = vm.comments.firstWhere(
                  (c) => c.id == target.id || c.replies.any((r) => r.id == target.id),
                  orElse: () => target,
                );
                setState(() => _replyingTo = parent);
              },
            ),
          ),
      ],
    );
  }

  void _showRatingSheet(BuildContext context, ComicDetailProvider vm, AuthProvider auth) {
    double tempRating = vm.userRating;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Beri Rating Komik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text(_ratingLabel(tempRating.toInt()), style: const TextStyle(fontSize: 14, color: AppTheme.textMedium)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setSheetState(() => tempRating = (i + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(i < tempRating ? Icons.star : Icons.star_border,
                        color: AppTheme.starYellow, size: 44),
                  ),
                )),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.accentGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        vm.submitRating(auth.currentUser?.id ?? '', tempRating);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Simpan Rating'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return '😞 Jelek';
      case 2: return '😐 Kurang';
      case 3: return '🙂 Lumayan';
      case 4: return '😊 Bagus';
      case 5: return '🤩 Luar Biasa!';
      default: return 'Pilih bintang di atas';
    }
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _StatBadge({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final ComicComment comment;
  final String currentUserId;
  final String authorId;
  final void Function(ComicComment) onReply;
  const _CommentCard({required this.comment, required this.currentUserId, required this.authorId, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentRow(comment, false),
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Column(
                children: comment.replies.map((reply) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 2, height: 60, color: AppTheme.divider, margin: const EdgeInsets.only(right: 8)),
                    Expanded(child: _buildCommentRow(reply, true)),
                  ],
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentRow(ComicComment c, bool isReply) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: AppTheme.surfaceGreen,
              child: Text(c.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: isReply ? 11 : 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
                    if (c.userId == authorId) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(100)),
                        child: const Text('Author', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(c.timeAgoDisplay(), style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: isReply ? 36 : 44, top: 4),
          child: Text(c.content, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        ),
        Padding(
          padding: EdgeInsets.only(left: isReply ? 36 : 44, top: 4),
          child: Row(
            children: [
              const Text('Like', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onReply(c),
                child: const Text('Reply', style: TextStyle(fontSize: 11, color: AppTheme.accentGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}