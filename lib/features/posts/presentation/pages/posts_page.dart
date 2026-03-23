// ─────────────────────────────────────────────────────────────────────────────
// POSTS PAGE  (Presentation Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is a "smart" widget — it connects to the BLoC.
// Its sole UI responsibility:
//   • Dispatch events (LoadPostsEvent on init, on pull-to-refresh)
//   • React to state changes (BlocBuilder rebuilds on each new state)
//   • Navigate to the detail page when a post is tapped
//
// It contains NO business logic and no data fetching.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/posts_bloc.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the load event as soon as the screen opens.
    // context.read<PostsBloc>() looks up the BLoC from the widget tree
    // (provided by BlocProvider in injection_container / main.dart).
    context.read<PostsBloc>().add(const LoadPostsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────────────────
          if (state is PostsLoading || state is PostsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ─────────────────────────────────────────────────────────
          if (state is PostsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<PostsBloc>().add(const LoadPostsEvent()),
            );
          }

          // ── Success ───────────────────────────────────────────────────────
          if (state is PostsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostsBloc>().add(const LoadPostsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pass the already-loaded post to avoid
                          // an extra network call for the detail view.
                          builder: (_) => PostDetailPage(postId: post.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Private helper widget ────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
