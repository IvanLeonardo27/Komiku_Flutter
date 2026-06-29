import 'package:flutter/foundation.dart';
import 'package:project_uas/models/models.dart';
import 'package:project_uas/services/network_service.dart';

// Auth Provider
class AuthProvider extends ChangeNotifier {
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage = 'Username dan password tidak boleh kosong';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final (success, userId) = await NetworkService.shared.login(username, password);
      if (success) {
        currentUser = User(id: userId.toString(), username: username, email: '$username@komiku.id');
      } else {
        errorMessage = 'Username atau password salah';
      }
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN ERROR] $e');
      errorMessage = 'Gagal terhubung ke server: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}

// Home Provider
class HomeProvider extends ChangeNotifier {
  List<KomikCategory> categories = [];
  List<Comic> featuredComics = [];
  List<Comic> popularComics = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        NetworkService.shared.getCategories(),
        NetworkService.shared.getComics(),
      ]);
      categories = results[0] as List<KomikCategory>;
      final comics = results[1] as List<Comic>;
      featuredComics = (comics..sort((a, b) => b.totalViews.compareTo(a.totalViews))).take(6).toList();
      popularComics = (comics..sort((a, b) => b.averageRating.compareTo(a.averageRating))).take(4).toList();
    } catch (_) {
      errorMessage = 'Gagal memuat data';
    }
    isLoading = false;
    notifyListeners();
  }
}

// Category Provider
class CategoryProvider extends ChangeNotifier {
  List<Comic> comicsInCategory = [];
  bool isLoading = false;

  Future<void> loadComics(String categoryName) async {
    isLoading = true;
    notifyListeners();
    try {
      comicsInCategory = await NetworkService.shared.getComicsByCategory(categoryName);
    } catch (_) {
      comicsInCategory = [];
    }
    isLoading = false;
    notifyListeners();
  }
}

// Comic Detail Provider
class ComicDetailProvider extends ChangeNotifier {
  Comic comic;
  List<Chapter> chapters = [];
  List<ComicComment> comments = [];
  double userRating = 0;
  String newComment = '';
  bool isSubmittingComment = false;
  bool isLoadingChapters = false;
  bool isLoadingComments = false;

  ComicDetailProvider(this.comic);

  Future<void> loadChapters() async {
    isLoadingChapters = true;
    notifyListeners();
    chapters = await NetworkService.shared.getChapters(comic.id);
    isLoadingChapters = false;
    notifyListeners();
  }

  Future<void> loadComments() async {
    isLoadingComments = true;
    notifyListeners();
    comments = await NetworkService.shared.getComments(comic.id);
    isLoadingComments = false;
    notifyListeners();
  }

  Future<void> refreshComic() async {
    final comics = await NetworkService.shared.getComics();
    final updated = comics.firstWhere((c) => c.id == comic.id, orElse: () => comic);
    comic = updated;
    notifyListeners();
  }

  Future<void> addView() async {
    await NetworkService.shared.addView(comic.id);
    comic.totalViews++;
    notifyListeners();
  }

  Future<void> loadUserRating(String userId) async {
    userRating = await NetworkService.shared.getUserRating(comic.id, userId);
    notifyListeners();
  }

  Future<void> submitComment(String userId, String username) async {
    if (newComment.trim().isEmpty) return;
    isSubmittingComment = true;
    notifyListeners();
    await NetworkService.shared.addComment(comic.id, userId, newComment);
    newComment = '';
    comic.totalComments++;
    await loadComments();
    isSubmittingComment = false;
    notifyListeners();
  }

  Future<void> submitReply(String parentId, String userId, String username, String content) async {
    isSubmittingComment = true;
    notifyListeners();
    await NetworkService.shared.addComment(comic.id, userId, content, parentId: parentId);
    comic.totalComments++;
    await loadComments();
    isSubmittingComment = false;
    notifyListeners();
  }

  Future<void> submitRating(String userId, double score) async {
    userRating = score;
    notifyListeners();
    await NetworkService.shared.addRating(comic.id, userId, score);
    await refreshComic();
  }
}

// Search Provider
class SearchProvider extends ChangeNotifier {
  String query = '';
  List<Comic> results = [];
  bool isSearching = false;

  Future<void> search() async {
    if (query.trim().isEmpty) { results = []; notifyListeners(); return; }
    isSearching = true;
    notifyListeners();
    results = await NetworkService.shared.searchComics(query);
    isSearching = false;
    notifyListeners();
  }

  void clearQuery() {
    query = '';
    results = [];
    notifyListeners();
  }
}

// Create Comic Provider
class CreateComicProvider extends ChangeNotifier {
  String title = '';
  String description = '';
  String posterURL = '';
  Set<String> selectedCategories = {};
  bool isPublishing = false;
  bool publishSuccess = false;
  String? errorMessage;

  bool get isValid => title.trim().isNotEmpty && selectedCategories.isNotEmpty && posterURL.trim().isNotEmpty;

  void toggleCategory(String name) {
    if (selectedCategories.contains(name)) {
      selectedCategories.remove(name);
    } else {
      selectedCategories.add(name);
    }
    notifyListeners();
  }

  Future<int?> publish(String authorId) async {
    if (!isValid) {
      errorMessage = 'Isi judul, poster URL, dan pilih minimal 1 kategori';
      notifyListeners();
      return null;
    }
    isPublishing = true;
    errorMessage = null;
    notifyListeners();
    final comicId = await NetworkService.shared.createComic(
      title, description, posterURL, authorId, selectedCategories.toList(),
    );
    isPublishing = false;
    if (comicId != null) {
      publishSuccess = true;
      resetForm();
    } else {
      errorMessage = 'Gagal mempublikasikan komik';
    }
    notifyListeners();
    return comicId;
  }

  void resetForm() {
    title = ''; description = ''; posterURL = '';
    selectedCategories = {}; publishSuccess = false;
    notifyListeners();
  }
}