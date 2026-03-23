// ─────────────────────────────────────────────────────────────────────────────
// POSTS STATES  (Presentation Layer — BLoC)
// ─────────────────────────────────────────────────────────────────────────────
//
// States represent the CURRENT CONDITION of the UI.
// The UI rebuilds whenever the BLoC emits a new state.
//
// Best practices:
//   • Model states as a sealed hierarchy (one base + concrete subclasses)
//   • Each state carries ONLY the data it needs
//   • Use Equatable so BlocBuilder skips redundant rebuilds
//
// UI pattern-matches on these states in BlocBuilder:
//   PostsInitial     → show nothing / splash
//   PostsLoading     → show spinner
//   PostsLoaded      → show list of posts
//   PostDetailLoaded → show single post detail
//   PostsError       → show error message with retry button
// ─────────────────────────────────────────────────────────────────────────────

part of 'posts_bloc.dart';

/// Base state class.
abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

/// Before any event has been dispatched.
class PostsInitial extends PostsState {
  const PostsInitial();
}

/// Waiting for data (remote fetch or cache read).
class PostsLoading extends PostsState {
  const PostsLoading();
}

/// Posts list successfully loaded.
class PostsLoaded extends PostsState {
  final List<Post> posts;
  const PostsLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

/// Single post detail successfully loaded.
class PostDetailLoaded extends PostsState {
  final Post post;
  const PostDetailLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

/// Something went wrong — holds the human-readable message from Failure.
class PostsError extends PostsState {
  final String message;
  const PostsError({required this.message});

  @override
  List<Object> get props => [message];
}
