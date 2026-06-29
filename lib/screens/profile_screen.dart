import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/network_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Comic> _myComics = [];
  bool _isLoading = false;

  int get _totalViews => _myComics.fold(0, (sum, c) => sum + c.totalViews);
  int get _totalComments => _myComics.fold(0, (sum, c) => sum + c.totalComments);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMyComics());
  }

  Future<void> _loadMyComics() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;
    setState(() => _isLoading = true);
    final comics = await NetworkService.shared.getComics();
    setState(() {
      _myComics = comics.where((c) => c.authorId == auth.currentUser!.id).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                ),
              ),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 24, left: 16, right: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.cream,
                    child: Text(
                      (auth.currentUser?.username.substring(0, 1) ?? 'K').toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(auth.currentUser?.username ?? 'Komikur',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(auth.currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(value: '${_myComics.length}', label: 'Komik Dibuat', icon: Icons.book),
                  const SizedBox(width: 8),
                  _StatCard(value: _totalViews >= 1000 ? '${_totalViews ~/ 1000}K' : '$_totalViews', label: 'Total Views', icon: Icons.visibility),
                  const SizedBox(width: 8),
                  _StatCard(value: '$_totalComments', label: 'Komentar', icon: Icons.chat_bubble),
                ],
              ),
            ),
            // My Comics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Komik Saya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const Spacer(),
                      Text(_myComics.isEmpty ? 'Belum ada komik' : '${_myComics.length} komik',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  else if (_myComics.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.add_box, size: 36, color: AppTheme.divider),
                            SizedBox(height: 8),
                            Text('Belum ada komik. Yuk mulai buat!', style: TextStyle(color: AppTheme.textLight)),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _myComics.length,
                        itemBuilder: (context, i) => _ComicCardVertical(comic: _myComics[i]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    _MenuRow(icon: Icons.person, title: 'Edit Profil', subtitle: 'Ubah username & foto', onTap: () {}),
                    _MenuRow(icon: Icons.notifications, title: 'Notifikasi', subtitle: 'Atur preferensi notifikasi', onTap: () {}),
                    _MenuRow(icon: Icons.help_outline, title: 'Bantuan', subtitle: 'FAQ & hubungi kami', onTap: () {}),
                    _MenuRow(icon: Icons.info_outline, title: 'Tentang Aplikasi', subtitle: 'Versi 1.0.0', onTap: () {}),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.error.withOpacity(0.12),
                        child: const Icon(Icons.logout, color: AppTheme.error, size: 18),
                      ),
                      title: const Text('Keluar', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keluar dari Akun?'),
                          content: const Text('Apakah kamu yakin ingin keluar?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                            TextButton(
                              onPressed: () { Navigator.pop(context); auth.logout(); },
                              child: const Text('Keluar', style: TextStyle(color: AppTheme.error)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentGreen, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textLight), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.surfaceGreen,
        child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 16),
      onTap: onTap,
    );
  }
}

class _ComicCardVertical extends StatelessWidget {
  final Comic comic;
  const _ComicCardVertical({required this.comic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: comic.posterURL, width: 130, height: 175, fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 130, height: 175, color: AppTheme.surfaceGreen),
              errorWidget: (_, __, ___) => Container(width: 130, height: 175, color: AppTheme.surfaceGreen, child: const Icon(Icons.book, color: AppTheme.lightGreen, size: 32)),
            ),
          ),
          const SizedBox(height: 4),
          Text(comic.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 10),
              Text(' ${comic.averageRating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10, color: AppTheme.textMedium)),
            ],
          ),
        ],
      ),
    );
  }
}