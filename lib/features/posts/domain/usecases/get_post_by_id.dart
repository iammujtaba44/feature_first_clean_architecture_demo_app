// ─────────────────────────────────────────────────────────────────────────────
// GET POST BY ID USE CASE  (Domain Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// When a use case needs input, define a [Params] class inside it.
// Params is just a value object — keep it immutable with Equatable.
//
// Why a typed Params class instead of plain `int id`?
//   • More descriptive call-sites: `usecase(Params(id: 42))`
//   • Easy to extend later (add filters, locale, etc.) without breaking callers
//   • Testable by value equality
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostById implements UseCase<Post, Params> {
  final PostRepository repository;

  const GetPostById(this.repository);

  @override
  Future<Either<Failure, Post>> call(Params params) {
    return repository.getPostById(params.id);
  }
}

/// Input parameter for [GetPostById].
class Params extends Equatable {
  final int id;
  const Params({required this.id});

  @override
  List<Object> get props => [id];
}
