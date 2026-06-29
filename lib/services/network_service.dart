import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_uas/models/models.dart';

class NetworkService {
  static final NetworkService shared = NetworkService._();
  NetworkService._();

  static const String baseURL = 'https://ubaya.cloud/flutter/160423189';

  Future<List<Comic>> getComics() async {
    final res = await http.get(Uri.parse('$baseURL/getComics.php'));
    final List data = jsonDecode(res.body);
    return data.map((e) => Comic.fromJson(e)).toList();
  }

  Future<List<KomikCategory>> getCategories() async {
    final res = await http.get(Uri.parse('$baseURL/getCategories.php'));
    final List data = jsonDecode(res.body);
    return data.map((e) => KomikCategory.fromJson(e)).toList();
  }

  Future<List<Chapter>> getChapters(String comicId) async {
    final res = await http.get(Uri.parse('$baseURL/getChapters.php?comic_id=$comicId'));
    final List data = jsonDecode(res.body);
    return data.map((e) => Chapter.fromJson(e)).toList();
  }

  Future<Chapter> getChapterDetail(String chapterId) async {
    final res = await http.get(Uri.parse('$baseURL/chapterDetail.php?id=$chapterId'));
    return Chapter.fromJson(jsonDecode(res.body));
  }

  Future<List<ComicComment>> getComments(String comicId) async {
    final res = await http.get(Uri.parse('$baseURL/getComments.php?comic_id=$comicId'));
    final List data = jsonDecode(res.body);
    return data.map((e) => ComicComment.fromJson(e)).toList();
  }

  Future<List<Comic>> searchComics(String keyword) async {
    final encoded = Uri.encodeComponent(keyword);
    final res = await http.get(Uri.parse('$baseURL/searchComics.php?keyword=$encoded'));
    final List data = jsonDecode(res.body);
    return data.map((e) => Comic.fromJson(e)).toList();
  }

  Future<List<Comic>> getComicsByCategory(String categoryName) async {
    final encoded = Uri.encodeComponent(categoryName);
    final res = await http.get(Uri.parse('$baseURL/getComicsByCategory.php?category=$encoded'));
    final List data = jsonDecode(res.body);
    return data.map((e) => Comic.fromJson(e)).toList();
  }

  Future<(bool, int)> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseURL/login.php'),
      body: {'username': username, 'password': password},
    );
    final data = jsonDecode(res.body);
    return (data['result'] == 'success', (data['user_id'] ?? 0) as int);
  }

  Future<int?> createComic(String title, String description, String posterURL, String authorId, List<String> categories) async {
    try {
      final res = await http.post(
        Uri.parse('$baseURL/createComic.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'title': title,
          'description': description,
          'poster_url': posterURL,
          'author_id': authorId,
          'categories': categories.join(','),
        },
      );
      // ignore: avoid_print
      print('[createComic] Status: ${res.statusCode}, Body: ${res.body}');
      if (res.statusCode != 200 || res.body.trim().isEmpty) return null;
      final data = jsonDecode(res.body);
      if (data['result'] == 'success') return int.tryParse(data['comic_id'].toString());
    } catch (e) {
      // ignore: avoid_print
      print('[createComic ERROR] $e');
    }
    return null;
  }

  Future<bool> addRating(String comicId, String userId, double rating) async {
    try {
      final res = await http.post(
        Uri.parse('$baseURL/addRating.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'comic_id': comicId,
          'user_id': userId,
          'rating': rating.toString(),
        },
      );
      // ignore: avoid_print
      print('[addRating] Status: ${res.statusCode}, Body: ${res.body}');
      if (res.statusCode != 200 || res.body.trim().isEmpty) return false;
      return jsonDecode(res.body)['result'] == 'success';
    } catch (e) {
      // ignore: avoid_print
      print('[addRating ERROR] $e');
      return false;
    }
  }

  Future<bool> addComment(String comicId, String userId, String content, {String? parentId}) async {
    final body = {'comic_id': comicId, 'user_id': userId, 'content': content};
    if (parentId != null) body['parent_id'] = parentId;
    final res = await http.post(
      Uri.parse('$baseURL/addComment.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    // ignore: avoid_print
    print('[addComment] Status: ${res.statusCode}, Body: ${res.body}');
    if (res.statusCode != 200 || res.body.trim().isEmpty) return false;
    return jsonDecode(res.body)['result'] == 'success';
  }

  Future<int?> createChapter(int comicId, String title, int chapterNumber) async {
    try {
      final res = await http.post(
        Uri.parse('$baseURL/createChapter.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'comic_id': comicId.toString(),
          'title': title,
          'chapter_number': chapterNumber.toString(),
        },
      );
      // ignore: avoid_print
      print('[createChapter] Status: ${res.statusCode}, Body: ${res.body}');
      if (res.statusCode != 200 || res.body.trim().isEmpty) return null;
      final data = jsonDecode(res.body);
      if (data['result'] == 'success') return int.tryParse(data['chapter_id'].toString());
    } catch (e) {
      // ignore: avoid_print
      print('[createChapter ERROR] $e');
    }
    return null;
  }

  Future<bool> addChapterPage(int chapterId, int pageNumber, String imageURL) async {
    try {
      final res = await http.post(
        Uri.parse('$baseURL/addChapterPage.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'chapter_id': chapterId.toString(),
          'page_number': pageNumber.toString(),
          'image_url': imageURL,
        },
      );
      // ignore: avoid_print
      print('[addChapterPage] Status: ${res.statusCode}, Body: ${res.body}');
      if (res.statusCode != 200 || res.body.trim().isEmpty) return false;
      return jsonDecode(res.body)['result'] == 'success';
    } catch (e) {
      // ignore: avoid_print
      print('[addChapterPage ERROR] $e');
      return false;
    }
  }

  Future<bool> addView(String comicId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseURL/addViews.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'comic_id': comicId},
      );
      // ignore: avoid_print
      print('[addView] Status: ${res.statusCode}, Body: ${res.body}');
      if (res.statusCode != 200 || res.body.trim().isEmpty) return false;
      return jsonDecode(res.body)['result'] == 'success';
    } catch (e) {
      // ignore: avoid_print
      print('[addView ERROR] $e');
      return false;
    }
  }

  Future<double> getUserRating(String comicId, String userId) async {
    try {
      final res = await http.get(Uri.parse('$baseURL/getUserRating.php?comic_id=$comicId&user_id=$userId'));
      if (res.statusCode != 200 || res.body.trim().isEmpty) return 0.0;
      final data = jsonDecode(res.body);
      return (data['rating'] ?? 0).toDouble();
    } catch (_) {
      return 0.0;
    }
  }
}