// ─────────────────────────────────────────────────────────────────────────────
// POST REPOSITORY IMPLEMENTATION  (Data Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is where all the Data layer plumbing comes together.
// It implements the Domain's [PostRepository] contract.
//
// Responsibilities:
//   1. Check connectivity via [NetworkInfo]
//   2. If online  → fetch from remote data source → cache → return
//   3. If offline → return cached data (or CacheFailure if none)
//   4. Catch Exceptions → convert to Failures (domain-friendly errors)
//
// KEY INSIGHT:
//   The Domain layer defines the WHAT (PostRepository abstract class).
//   This class defines the HOW. The BLoC never imports this class — it
//   only knows about the abstract [PostRepository].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_data_source.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ─── getAllPosts ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Post>>> getAllPosts() async {
    if (await networkInfo.isConnected) {
      // Online path
      try {
        final remotePosts = await remoteDataSource.getAllPosts();
        // Cache the fresh data for offline use
        await localDataSource.cachePosts(remotePosts);
        return Right(remotePosts);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Offline path — try returning cached data
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        return Right(cachedPosts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  // ─── getPostById ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final post = await remoteDataSource.getPostById(id);
        return Right(post);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Offline: try to find the post in the local cache
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        final post = cachedPosts.firstWhere(
          (p) => p.id == id,
          orElse: () => throw const CacheException(
            message: 'Post not available offline.',
          ),
        );
        return Right(post);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}
