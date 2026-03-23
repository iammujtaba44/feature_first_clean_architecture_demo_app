// ─────────────────────────────────────────────────────────────────────────────
// POST REPOSITORY  (Domain Layer — Interface / Contract)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is just an ABSTRACT CLASS — a contract, not an implementation.
// The Domain layer defines WHAT the repository can do.
// The Data layer defines HOW it actually does it.
//
// Why separate interface from implementation?
//   • Domain has zero dependency on Flutter, HTTP, SharedPreferences, etc.
//   • You can swap implementations (REST → GraphQL, SQLite → Hive) freely
//   • Unit tests can use a MockPostRepository without touching real data
//
// The return type `Either<Failure, T>` means:
//   Left  → something went wrong (Failure)
//   Right → success (the data)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  /// Fetches all posts. Returns cached data when offline.
  Future<Either<Failure, List<Post>>> getAllPosts();

  /// Fetches a single post by [id].
  Future<Either<Failure, Post>> getPostById(int id);
}
