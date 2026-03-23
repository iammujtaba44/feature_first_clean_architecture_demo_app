// ─────────────────────────────────────────────────────────────────────────────
// POST LOCAL DATA SOURCE  (Data Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// Responsible for reading and writing to the LOCAL cache (SharedPreferences).
// Rules:
//   ✅ Returns/accepts Models
//   ✅ Throws [CacheException] when data is absent or corrupt
//   ❌ Never calls the network
//
// SharedPreferences stores only primitives, so we JSON-encode lists/objects.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

/// Contract for the local data source.
abstract class PostLocalDataSource {
  /// Returns cached posts from SharedPreferences.
  /// Throws [CacheException] if nothing is cached.
  Future<List<PostModel>> getCachedPosts();

  /// Saves posts to SharedPreferences for offline use.
  Future<void> cachePosts(List<PostModel> posts);
}

/// Implementation using SharedPreferences.
class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Key under which the posts JSON is stored.
  static const _cachedPostsKey = 'CACHED_POSTS';

  const PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PostModel>> getCachedPosts() async {
    final jsonString = sharedPreferences.getString(_cachedPostsKey);

    if (jsonString == null) {
      throw const CacheException(message: 'No cached posts found.');
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List;
    return jsonList
        .map((json) => PostModel.fromCache(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    final jsonString = json.encode(
      posts.map((post) => post.toJson()).toList(),
    );
    await sharedPreferences.setString(_cachedPostsKey, jsonString);
  }
}
