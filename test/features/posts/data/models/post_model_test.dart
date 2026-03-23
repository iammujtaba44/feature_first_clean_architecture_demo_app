// ─────────────────────────────────────────────────────────────────────────────
// UNIT TEST: PostModel
// ─────────────────────────────────────────────────────────────────────────────
//
// Tests that PostModel correctly:
//   • Extends Post (is a subtype of the entity)
//   • Deserializes from JSON
//   • Serializes back to JSON without data loss
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch_demo/features/posts/data/models/post_model.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/entities/post.dart';

void main() {
  const tPostModel = PostModel(
    id: 1,
    userId: 1,
    title: 'sunt aut facere repellat',
    body: 'quia et suscipit suscipit...',
  );

  final tJson = {
    'id': 1,
    'userId': 1,
    'title': 'sunt aut facere repellat',
    'body': 'quia et suscipit suscipit...',
  };

  // ── Is a Post ──────────────────────────────────────────────────────────────
  test('should be a subclass of Post entity', () {
    expect(tPostModel, isA<Post>());
  });

  // ── fromJson ───────────────────────────────────────────────────────────────
  group('fromJson', () {
    test('should return a valid PostModel from JSON', () {
      final result = PostModel.fromJson(tJson);
      expect(result, tPostModel);
    });
  });

  // ── toJson ────────────────────────────────────────────────────────────────
  group('toJson', () {
    test('should return a JSON map with correct data', () {
      final result = tPostModel.toJson();
      expect(result, tJson);
    });
  });
}
