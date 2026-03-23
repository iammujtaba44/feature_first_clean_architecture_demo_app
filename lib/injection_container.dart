// ─────────────────────────────────────────────────────────────────────────────
// INJECTION CONTAINER (Dependency Injection via get_it)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the COMPOSITION ROOT — the single place where the entire
// dependency graph is wired together.
//
// The dependency graph flows INWARD following the dependency rule:
//
//   HTTP Client
//       └── PostRemoteDataSource
//   SharedPreferences
//       └── PostLocalDataSource
//   Connectivity
//       └── NetworkInfo
//   RemoteDataSource + LocalDataSource + NetworkInfo
//       └── PostRepositoryImpl  (implements PostRepository)
//   PostRepository
//       ├── GetAllPosts
//       └── GetPostById
//   GetAllPosts + GetPostById
//       └── PostsBloc
//
// No layer above knows about the layers below — they only know about
// the INTERFACE (abstract class), not the implementation.
//
// `sl` stands for "service locator" — a common convention.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/posts/data/datasources/post_local_data_source.dart';
import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/repositories/post_repository.dart';
import 'features/posts/domain/usecases/get_all_posts.dart';
import 'features/posts/domain/usecases/get_post_by_id.dart';
import 'features/posts/presentation/bloc/posts_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Call this once in [main] before [runApp].
Future<void> init() async {
  // ─── BLoC ──────────────────────────────────────────────────────────────────
  // Registered as factory: a NEW instance is created each time it's requested.
  // This prevents stale state when navigating back and forth.
  sl.registerFactory(
    () => PostsBloc(
      getAllPosts: sl(),
      getPostById: sl(),
    ),
  );

  // ─── Use Cases ─────────────────────────────────────────────────────────────
  // Registered as lazy singletons: created once on first use, reused after.
  sl.registerLazySingleton(() => GetAllPosts(sl()));
  sl.registerLazySingleton(() => GetPostById(sl()));

  // ─── Repository ────────────────────────────────────────────────────────────
  // We register the IMPL against the INTERFACE so callers receive PostRepository.
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ─── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PostLocalDataSource>(
    () => PostLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ─── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // ─── External (third-party) ────────────────────────────────────────────────
  // SharedPreferences requires async init, so we await it here.
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}
