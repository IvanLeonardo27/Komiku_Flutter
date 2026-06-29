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
    final res = await http.post(Uri.parse('$baseURL/createComic.php'), body: {
      'title': title, 'description': description, 'poster_url': posterURL,
      'author_id': authorId, 'categories': categories.join(','),
    });
    final data = jsonDecode(res.body);
    if (data['result'] == 'success') return data['comic_id'];
    return null;
  }

  Future<bool> addRating(String comicId, String userId, double rating) async {
    final res = await http.post(Uri.parse('$baseURL/addRating.php'), body: {
      'comic_id': comicId, 'user_id': userId, 'rating': rating.toString(),
    });
    return jsonDecode(res.body)['result'] == 'success';
  }

  Future<bool> addComment(String comicId, String userId, String content, {String? parentId}) async {
    final body = {'comic_id': comicId, 'user_id': userId, 'content': content};
    if (parentId != null) body['parent_id'] = parentId;
    final res = await http.post(Uri.parse('$baseURL/addComment.php'), body: body);
    return jsonDecode(res.body)['result'] == 'success';
  }

  Future<int?> createChapter(int comicId, String title, int chapterNumber) async {
    final res = await http.post(Uri.parse('$baseURL/createChapter.php'), body: {
      'comic_id': comicId.toString(), 'title': title, 'chapter_number': chapterNumber.toString(),
    });
    final data = jsonDecode(res.body);
    if (data['result'] == 'success') return data['chapter_id'];
    return null;
  }

  Future<bool> addChapterPage(int chapterId, int pageNumber, String imageURL) async {
    final res = await http.post(Uri.parse('$baseURL/addChapterPage.php'), body: {
      'chapter_id': chapterId.toString(), 'page_number': pageNumber.toString(), 'image_url': imageURL,
    });
    return jsonDecode(res.body)['result'] == 'success';
  }

  Future<bool> addView(String comicId) async {
    final res = await http.post(Uri.parse('$baseURL/addViews.php'), body: {'comic_id': comicId});
    return jsonDecode(res.body)['result'] == 'success';
  }

  Future<double> getUserRating(String comicId, String userId) async {
    final res = await http.get(Uri.parse('$baseURL/getUserRating.php?comic_id=$comicId&user_id=$userId'));
    return (jsonDecode(res.body)['rating'] ?? 0).toDouble();
  }
}