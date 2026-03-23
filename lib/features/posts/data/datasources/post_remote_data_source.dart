// ─────────────────────────────────────────────────────────────────────────────
// POST REMOTE DATA SOURCE  (Data Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// Responsible for ALL communication with the remote API.
// Rules:
//   ✅ Returns Models, not Entities
//   ✅ Throws Exceptions (not Failures) on error
//   ✅ Has no business logic — just fetch & parse
//   ❌ Never talks to the local cache (that's the local data source's job)
//
// We use https://jsonplaceholder.typicode.com — a free fake REST API.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

/// Contract for the remote data source.
abstract class PostRemoteDataSource {
  /// Calls GET /posts
  /// Throws [ServerException] on failure.
  Future<List<PostModel>> getAllPosts();

  /// Calls GET /posts/{id}
  /// Throws [ServerException] on failure.
  Future<PostModel> getPostById(int id);
}

/// Implementation using the `http` package and JSONPlaceholder API.
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final http.Client client;

  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  const PostRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostModel>> getAllPosts() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body) as List;
      return jsonList
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(
        message: 'Server returned ${response.statusCode}',
      );
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw ServerException(
        message: 'Server returned ${response.statusCode}',
      );
    }
  }
}
