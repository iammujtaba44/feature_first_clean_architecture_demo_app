// ─────────────────────────────────────────────────────────────────────────────
// POSTS BLOC  (Presentation Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// The BLoC is the "brain" of the Presentation layer.
// It:
//   • Receives Events from the UI
//   • Delegates business logic to Use Cases (never imports Repository directly)
//   • Emits States back to the UI
//
// The BLoC has NO knowledge of HTTP, SharedPreferences, or Widget trees.
// It only knows:
//   • Domain Entities (Post)
//   • Use Cases (GetAllPosts, GetPostById)
//   • Failures (for error messages)
//
// This separation makes the BLoC trivial to unit-test — just pass mock use cases.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_all_posts.dart';
import '../../domain/usecases/get_post_by_id.dart';
import '../../../../core/usecases/usecase.dart';

// The `part` directive splits BLoC into separate files for readability
// while keeping them in the same library scope.
part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetAllPosts getAllPosts;
  final GetPostById getPostById;

  PostsBloc({
    required this.getAllPosts,
    required this.getPostById,
  }) : super(const PostsInitial()) {
    // Register event handlers
    on<LoadPostsEvent>(_onLoadPosts);
    on<LoadPostDetailEvent>(_onLoadPostDetail);
  }

  // ─── Handler: LoadPostsEvent ──────────────────────────────────────────────

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    // Call the use case — it returns Either<Failure, List<Post>>
    final result = await getAllPosts(NoParams());

    // fold: left = failure handler, right = success handler
    result.fold(
      (failure) => emit(PostsError(message: failure.message)),
      (posts) => emit(PostsLoaded(posts: posts)),
    );
  }

  // ─── Handler: LoadPostDetailEvent ────────────────────────────────────────

  Future<void> _onLoadPostDetail(
    LoadPostDetailEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final result = await getPostById(Params(id: event.postId));

    result.fold(
      (failure) => emit(PostsError(message: failure.message)),
      (post) => emit(PostDetailLoaded(post: post)),
    );
  }
}
