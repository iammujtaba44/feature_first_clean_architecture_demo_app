// ─────────────────────────────────────────────────────────────────────────────
// POSTS EVENTS  (Presentation Layer — BLoC)
// ─────────────────────────────────────────────────────────────────────────────
//
// Events represent USER INTENTIONS / UI interactions.
// The UI dispatches events; the BLoC handles them and emits new states.
//
// Think of events as commands: "Hey BLoC, the user wants to do X."
// Events should be:
//   • Immutable
//   • Named in past tense or as user actions (LoadPosts, RefreshPosts)
//   • Comparable by value (Equatable) so BLoC's transformations work correctly
// ─────────────────────────────────────────────────────────────────────────────

part of 'posts_bloc.dart';

/// Base event class.
abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched when the posts list screen is first opened,
/// or when the user pulls to refresh.
class LoadPostsEvent extends PostsEvent {
  const LoadPostsEvent();
}

/// Dispatched when the user taps a post to view its detail.
class LoadPostDetailEvent extends PostsEvent {
  final int postId;
  const LoadPostDetailEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}
