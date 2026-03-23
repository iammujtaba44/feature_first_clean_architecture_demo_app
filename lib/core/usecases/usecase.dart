// ─────────────────────────────────────────────────────────────────────────────
// USE CASE CONTRACT
// ─────────────────────────────────────────────────────────────────────────────
//
// Every Use Case in the app implements this generic interface.
// This enforces a single public method `call()` which:
//   • accepts typed [Params]
//   • returns Either<Failure, Type> — left = error, right = success
//
// Benefits:
//   • Uniform API across all use cases
//   • Easy to mock in tests
//   • BLoC only needs to call `usecase(params)` — no implementation details
//
// [NoParams] is used when a use case needs no input.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Generic use case interface.
/// [T] = the success return type, [Params] = the input parameters type.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use this when a use case requires no input parameters.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
