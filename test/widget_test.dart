// ─────────────────────────────────────────────────────────────────────────────
// WIDGET TEST: PostsPage
// ─────────────────────────────────────────────────────────────────────────────
//
// Widget tests verify the UI reacts correctly to BLoC state changes.
// We use MockBloc (from bloc_test) — no code generation needed.
//
// Pattern:
//   • Create a MockPostsBloc and seed its state with whenListen
//   • Wrap PostsPage in a BlocProvider using the mock
//   • Assert the correct widgets are rendered for each state
// ─────────────────────────────────────────────────────────────────────────────

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_arch_demo/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_arch_demo/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:flutter_clean_arch_demo/features/posts/presentation/pages/posts_page.dart';

// MockBloc from bloc_test handles state/stream plumbing without code generation.
class MockPostsBloc extends MockBloc<PostsEvent, PostsState>
    implements PostsBloc {}

void main() {
  group('PostsPage', () {
    late MockPostsBloc mockBloc;

    setUp(() {
      mockBloc = MockPostsBloc();
    });

    tearDown(() => mockBloc.close());

    Widget buildSubject() => MaterialApp(
          home: BlocProvider<PostsBloc>.value(
            value: mockBloc,
            child: const PostsPage(),
          ),
        );

    testWidgets('shows AppBar with "Posts" title', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([const PostsInitial()]),
        initialState: const PostsInitial(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Posts'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when state is PostsLoading',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([const PostsLoading()]),
        initialState: const PostsLoading(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows post titles when state is PostsLoaded', (tester) async {
      const tPosts = [
        Post(id: 1, userId: 1, title: 'Test Title', body: 'Test Body'),
      ];

      whenListen(
        mockBloc,
        Stream.fromIterable([const PostsLoaded(posts: tPosts)]),
        initialState: const PostsLoaded(posts: tPosts),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // PostCard renders titles in upper case
      expect(find.text('TEST TITLE'), findsOneWidget);
    });

    testWidgets('shows error message when state is PostsError', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(
            [const PostsError(message: 'Something went wrong')]),
        initialState: const PostsError(message: 'Something went wrong'),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
