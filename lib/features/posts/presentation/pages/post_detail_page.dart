// ─────────────────────────────────────────────────────────────────────────────
// POST DETAIL PAGE  (Presentation Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// Displays a single post's full content.
// Demonstrates how to trigger a second use case (GetPostById) from the BLoC
// using a different event (LoadPostDetailEvent).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/posts_bloc.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PostsBloc>()
        .add(LoadPostDetailEvent(postId: widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────────────────
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ─────────────────────────────────────────────────────────
          if (state is PostsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PostsBloc>()
                        .add(LoadPostDetailEvent(postId: widget.postId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ── Success ───────────────────────────────────────────────────────
          if (state is PostDetailLoaded) {
            final post = state.post;
            final theme = Theme.of(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Post #${post.id}  ·  User #${post.userId}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    post.title.toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 8),

                  // Body
                  Text(
                    post.body,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Architecture callout card
                  _ArchNote(
                    title: '🏛 Architecture Note',
                    body:
                        'This data came from GetPostById use case → '
                        'PostRepository → PostRemoteDataSource (or cache when offline). '
                        'The BLoC only called usecase(Params(id: ${post.id})) — '
                        'it never touched HTTP or SharedPreferences directly.',
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Architecture callout widget ─────────────────────────────────────────────

class _ArchNote extends StatelessWidget {
  final String title;
  final String body;

  const _ArchNote({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
