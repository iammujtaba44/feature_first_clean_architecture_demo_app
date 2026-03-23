// ─────────────────────────────────────────────────────────────────────────────
// POST MODEL  (Data Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// A Model is an EXTENSION of the Domain Entity.
// It inherits all entity fields AND adds serialization logic.
//
// Why extend instead of duplicate?
//   • The BLoC and UI still work with [Post] (the entity)
//   • Serialization stays isolated in the Data layer
//   • If the API changes its field names, you only update the model
//
// PostModel CAN be used anywhere Post is expected (Liskov substitution),
// but the domain and presentation layers never import PostModel directly.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  // ─── JSON (Remote API) ────────────────────────────────────────────────────

  /// Creates a [PostModel] from a JSON map returned by the remote API.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Converts this model back to a JSON map (used when sending data to API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  // ─── Local Cache (SharedPreferences) ─────────────────────────────────────

  /// Same as [fromJson] — SharedPreferences stores JSON strings,
  /// so we decode the same map structure after parsing.
  factory PostModel.fromCache(Map<String, dynamic> json) {
    return PostModel.fromJson(json);
  }
}
