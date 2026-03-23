// ─────────────────────────────────────────────────────────────────────────────
// UNIT TEST: GetAllPosts Use Case
// ─────────────────────────────────────────────────────────────────────────────
//
// This test demonstrates WHY clean architecture makes testing easy:
//   • We mock the PostRepository interface — no HTTP, no DB, no Flutter needed
//   • The test is pure Dart — fast and deterministic
//   • The test proves the use case delegates correctly to the repository
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_clean_arch_demo/core/usecases/usecase.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/entities/post.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_clean_arch_demo/features/posts/domain/usecases/get_all_posts.dart';

// @GenerateMocks creates a MockPostRepository class automatically.
// Run: flutter pub run build_runner build
@GenerateMocks([PostRepository])
import 'get_all_posts_test.mocks.dart';

void main() {
  late GetAllPosts usecase;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    usecase = GetAllPosts(mockRepository);
  });

  const tPosts = [
    Post(id: 1, userId: 1, title: 'Test Title', body: 'Test Body'),
  ];

  test('should get list of posts from the repository', () async {
    // Arrange: tell the mock what to return
    when(mockRepository.getAllPosts())
        .thenAnswer((_) async => const Right(tPosts));

    // Act: call the use case
    final result = await usecase(NoParams());

    // Assert: result matches expected, and repository was called exactly once
    expect(result, const Right(tPosts));
    verify(mockRepository.getAllPosts());
    verifyNoMoreInteractions(mockRepository);
  });
}
