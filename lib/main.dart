// ─────────────────────────────────────────────────────────────────────────────
// MAIN  —  App entry point
// ─────────────────────────────────────────────────────────────────────────────
//
// Two things happen here before the UI starts:
//   1. Flutter engine is initialized (WidgetsFlutterBinding.ensureInitialized)
//   2. Dependency injection graph is built (injection_container.init())
//
// Everything else is delegated to [MyApp] → [PostsPage].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/posts/presentation/bloc/posts_bloc.dart';
import 'features/posts/presentation/pages/posts_page.dart';
import 'injection_container.dart' as di;

void main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Wire up the entire dependency graph
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Material You purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // ─── BlocProvider ───────────────────────────────────────────────────────
      // We wrap the home route in a BlocProvider so PostsPage AND
      // PostDetailPage (pushed on top) can both access the SAME PostsBloc
      // instance via context.read<PostsBloc>().
      home: BlocProvider(
        create: (_) => di.sl<PostsBloc>(),
        child: const PostsPage(),
      ),
    );
  }
}
