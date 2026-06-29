class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageURL;

  User({required this.id, required this.username, required this.email, this.profileImageURL});
}

class KomikCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final int comicCount;

  KomikCategory({required this.id, required this.name, required this.iconName, required this.colorHex, required this.comicCount});

  factory KomikCategory.fromJson(Map<String, dynamic> json) {
    return KomikCategory(
      id: json['id'].toString(),
      name: json['name'],
      iconName: json['iconName'],
      colorHex: json['colorHex'],
      comicCount: json['comicCount'],
    );
  }
}

class Comic {
  final String id;
  final String title;
  final String posterURL;
  final List<String> categories;
  double averageRating;
  int totalRatings;
  int totalViews;
  int totalComments;
  final String authorId;
  final String authorUsername;
  final List<Chapter> chapters;
  final String description;

  int get chapterCount => chapters.length;

  Comic({
    required this.id, required this.title, required this.posterURL,
    required this.categories, required this.averageRating, required this.totalRatings,
    required this.totalViews, required this.totalComments, required this.authorId,
    required this.authorUsername, required this.chapters, required this.description,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'].toString(),
      title: json['title'],
      posterURL: json['posterURL'],
      categories: (json['categories'] as List? ?? []).map((e) {
        if (e is Map) {
          return (e['name'] ?? '').toString();
        }
        return e.toString();
      }).toList(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      authorId: json['authorId'].toString(),
      authorUsername: json['authorUsername'] ?? '',
      chapters: (json['chapters'] as List? ?? []).map((c) => Chapter.fromJson(c)).toList(),
      description: json['description'] ?? '',
    );
  }
}

class Chapter {
  final String id;
  final int number;
  final String title;
  List<String> pages;
  final DateTime uploadedAt;

  Chapter({required this.id, required this.number, required this.title, required this.pages, DateTime? uploadedAt})
      : uploadedAt = uploadedAt ?? DateTime.now();

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'].toString(),
      number: int.tryParse(json['number'].toString()) ?? 0,
      title: json['title'],
      pages: List<String>.from(json['pages'] ?? []),
      uploadedAt: json['uploadedAt'] != null ? DateTime.tryParse(json['uploadedAt']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class ComicComment {
  final String id;
  final String comicId;
  final String userId;
  final String username;
  final String content;
  List<ComicComment> replies;
  final DateTime createdAt;
  final int likeCount;

  ComicComment({
    required this.id, required this.comicId, required this.userId,
    required this.username, required this.content, required this.replies,
    DateTime? createdAt, this.likeCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ComicComment.fromJson(Map<String, dynamic> json) {
    final formatter = DateTime.tryParse(json['createdAt'] ?? '');
    return ComicComment(
      id: json['id'].toString(),
      comicId: json['comicId'].toString(),
      userId: json['userId'].toString(),
      username: json['username'],
      content: json['content'],
      replies: (json['replies'] as List? ?? []).map((r) => ComicComment.fromJson(r)).toList(),
      createdAt: formatter,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  String timeAgoDisplay() {
    final seconds = DateTime.now().difference(createdAt).inSeconds;
    if (seconds < 60) return 'Baru saja';
    if (seconds < 3600) return '${seconds ~/ 60} menit lalu';
    if (seconds < 86400) return '${seconds ~/ 3600} jam lalu';
    if (seconds < 86400 * 30) return '${seconds ~/ 86400} hari lalu';
    if (seconds < 86400 * 365) return '${seconds ~/ (86400 * 30)} bulan lalu';
    return '${seconds ~/ (86400 * 365)} tahun lalu';
  }
}