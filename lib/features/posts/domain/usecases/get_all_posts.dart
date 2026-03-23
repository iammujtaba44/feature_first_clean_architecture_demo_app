// ─────────────────────────────────────────────────────────────────────────────
// GET ALL POSTS USE CASE  (Domain Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// A Use Case encapsulates a SINGLE user action / business operation.
// It:
//   • Receives input via Params (NoParams here — no filters needed)
//   • Calls the repository (via interface, not concrete class)
//   • Returns Either<Failure, Result>
//
// Use Cases are the HEART of Clean Architecture. The BLoC delegates all
// business logic to use cases — BLoC itself stays thin.
//
// One use case = one responsibility. Don't combine "get all" and "search"
// into one use case just to save a file.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetAllPosts implements UseCase<List<Post>, NoParams> {
  final PostRepository repository;

  const GetAllPosts(this.repository);

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) {
    // Delegates directly to the repository — business logic goes here
    // if you need it (sorting, filtering, pagination, etc.)
    return repository.getAllPosts();
  }
}
