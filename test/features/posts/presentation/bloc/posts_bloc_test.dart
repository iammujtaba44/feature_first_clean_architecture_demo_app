// ─────────────────────────────────────────────────────────────────────────────
// UNIT TEST: PostsBloc
// ─────────────────────────────────────────────────────────────────────────────
//
// BLoC tests are state-machine tests:
//   • Given this initial state...
//   • When this event is dispatched...
//   • Then these states are emitted in order
//
// blocTest from package:bloc_test makes this declarative and readable.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_clean_arch_demo/core/error/failures.dart';
import 'package:flutter_clean_arch_demo/core/usecases/usecase.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/usecases/get_all_posts.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:flutter_clean_arch_demo/features/posts/presentation/bloc/posts_bloc.dart';

@GenerateMocks([GetAllPosts, GetPostById])
import 'posts_bloc_test.mocks.dart';

void main() {
  late PostsBloc bloc;
  late MockGetAllPosts mockGetAllPosts;
  late MockGetPostById mockGetPostById;

  setUp(() {
    mockGetAllPosts = MockGetAllPosts();
    mockGetPostById = MockGetPostById();
    bloc = PostsBloc(
      getAllPosts: mockGetAllPosts,
      getPostById: mockGetPostById,
    );
  });

  tearDown(() => bloc.close());

  const tPosts = [
    Post(id: 1, userId: 1, title: 'Title 1', body: 'Body 1'),
    Post(id: 2, userId: 1, title: 'Title 2', body: 'Body 2'),
  ];

  // ── LoadPostsEvent ────────────────────────────────────────────────────────

  group('LoadPostsEvent', () {
    blocTest<PostsBloc, PostsState>(
      'emits [PostsLoading, PostsLoaded] when posts are loaded successfully',
      build: () {
        when(mockGetAllPosts(NoParams()))
            .thenAnswer((_) async => const Right(tPosts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPostsEvent()),
      expect: () => [
        const PostsLoading(),
        const PostsLoaded(posts: tPosts),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'emits [PostsLoading, PostsError] when loading fails',
      build: () {
        when(mockGetAllPosts(NoParams())).thenAnswer(
          (_) async => const Left(ServerFailure()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPostsEvent()),
      expect: () => [
        const PostsLoading(),
        isA<PostsError>(),
      ],
    );
  });
}
