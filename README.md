# Flutter Clean Architecture Demo

A fully functional Flutter demo app built to teach **Clean Architecture** to junior developers.
It fetches posts from [JSONPlaceholder](https://jsonplaceholder.typicode.com), caches them offline, and displays them in a polished Material 3 UI.

---

## What You Will Learn

- How to split code into **three independent layers** (Data → Domain → Presentation)
- How to use **BLoC** for state management the right way
- How to handle **errors cleanly** with `Either<Failure, Success>`
- How to use **dependency injection** with `get_it`
- How to write **unit tests** for use cases and BLoC without touching the network

---

## Architecture Overview

Clean Architecture enforces a strict **dependency rule**:

> Inner layers know nothing about outer layers.
> Outer layers depend on inner layers — never the reverse.

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│  (BLoC · Pages · Widgets)                               │
│  → Dispatches Events, renders States                    │
│  → Knows Domain Entities + Use Cases ONLY               │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER  ★                      │
│  (Entities · Repository Interfaces · Use Cases)         │
│  → Pure Dart — zero Flutter / HTTP / DB imports         │
│  → The heart of the app; most stable layer              │
├─────────────────────────────────────────────────────────┤
│                     DATA LAYER                          │
│  (Models · Remote & Local DataSources · Repo Impl)      │
│  → Talks to APIs and databases                          │
│  → Converts Exceptions → Failures                       │
│  → Implements Domain Repository contracts               │
└─────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
lib/
├── core/                          # Shared across all features
│   ├── error/
│   │   ├── exceptions.dart        # Raw exceptions (Data layer only)
│   │   └── failures.dart          # Domain-friendly errors (Equatable)
│   ├── network/
│   │   └── network_info.dart      # Connectivity abstraction
│   └── usecases/
│       └── usecase.dart           # UseCase<Type, Params> contract
│
├── features/
│   └── posts/
│       ├── data/                  # DATA LAYER
│       │   ├── datasources/
│       │   │   ├── post_remote_data_source.dart   # HTTP calls
│       │   │   └── post_local_data_source.dart    # SharedPreferences cache
│       │   ├── models/
│       │   │   └── post_model.dart                # Entity + JSON serialization
│       │   └── repositories/
│       │       └── post_repository_impl.dart      # online/offline logic
│       │
│       ├── domain/                # DOMAIN LAYER (pure Dart)
│       │   ├── entities/
│       │   │   └── post.dart                      # Business object
│       │   ├── repositories/
│       │   │   └── post_repository.dart           # Abstract contract
│       │   └── usecases/
│       │       ├── get_all_posts.dart             # Single responsibility
│       │       └── get_post_by_id.dart
│       │
│       └── presentation/          # PRESENTATION LAYER
│           ├── bloc/
│           │   ├── posts_bloc.dart
│           │   ├── posts_event.dart
│           │   └── posts_state.dart
│           ├── pages/
│           │   ├── posts_page.dart
│           │   └── post_detail_page.dart
│           └── widgets/
│               └── post_card.dart
│
├── injection_container.dart       # Dependency graph composition root
└── main.dart
```

---

## Key Concepts Explained

### 1. Entity vs Model

| | Entity (`domain/`) | Model (`data/`) |
|---|---|---|
| Location | Domain layer | Data layer |
| Imports | Only `equatable` | Entity + `dart:convert` |
| Has `fromJson`? | No | Yes |
| Used by BLoC? | Yes | Never directly |

### 2. Repository Pattern

```
Domain defines the CONTRACT (abstract class):
  PostRepository { getAllPosts() }

Data provides the IMPLEMENTATION:
  PostRepositoryImpl implements PostRepository {
    if (online) → remote → cache → return
    if (offline) → return cache
  }

BLoC only imports PostRepository (the contract), never the Impl.
```

### 3. Either<Failure, Success>

Instead of try/catch scattered across the codebase, every operation returns:

```dart
Either<Failure, List<Post>>
  Left(ServerFailure())   // Something went wrong
  Right([post1, post2])   // Success
```

The BLoC uses `.fold()` to handle both cases cleanly:
```dart
result.fold(
  (failure) => emit(PostsError(message: failure.message)),
  (posts)   => emit(PostsLoaded(posts: posts)),
);
```

### 4. Dependency Flow

```
main.dart
  └── injection_container.dart   (wires everything together)
        └── PostsBloc
              ├── GetAllPosts
              │     └── PostRepository (interface)
              │           └── PostRepositoryImpl
              │                 ├── PostRemoteDataSource → http.Client
              │                 ├── PostLocalDataSource  → SharedPreferences
              │                 └── NetworkInfo          → Connectivity
              └── GetPostById
                    └── (same PostRepository instance)
```

---

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection (service locator) |
| `dartz` | `Either` type for functional error handling |
| `http` | HTTP networking |
| `shared_preferences` | Local caching |
| `connectivity_plus` | Online/offline detection |
| `equatable` | Value equality |
| `mockito` | Mocking for unit tests |

---

## Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate mock files for tests
dart run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run

# 4. Run tests
flutter test
```

---

## How Data Flows (Online)

```
User opens app
  → PostsPage.initState() dispatches LoadPostsEvent
  → PostsBloc._onLoadPosts() called
  → GetAllPosts(NoParams()) use case called
  → PostRepositoryImpl.getAllPosts() called
  → NetworkInfo.isConnected == true
  → PostRemoteDataSource.getAllPosts() → GET /posts
  → JSON parsed into List<PostModel>
  → Cached to SharedPreferences
  → Right(posts) returned up the chain
  → PostsBloc emits PostsLoaded(posts)
  → BlocBuilder rebuilds UI with ListView
```

## How Data Flows (Offline)

```
User opens app with no internet
  → (same path until NetworkInfo check)
  → NetworkInfo.isConnected == false
  → PostLocalDataSource.getCachedPosts() called
  → Reads JSON from SharedPreferences
  → Right(cachedPosts) returned

  If no cache exists:
  → CacheException thrown → caught by repo → CacheFailure
  → PostsBloc emits PostsError(message: "No cached data available.")
```

---

## License

MIT — free to use, share, and modify.
