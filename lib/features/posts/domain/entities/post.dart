// ─────────────────────────────────────────────────────────────────────────────
// POST ENTITY  (Domain Layer)
// ─────────────────────────────────────────────────────────────────────────────
//
// An Entity is the PUREST representation of a business object.
// Key rules:
//   ✅ Contains ONLY business-relevant fields — no JSON keys, no database cols
//   ✅ Has NO imports from Flutter, HTTP packages, or any external library
//      (only equatable is allowed as it is a pure Dart utility)
//   ✅ Defines business logic / validation if needed
//   ❌ Never contains `fromJson` / `toJson` — that lives in the Model (data layer)
//
// This is the object the BLoC, use cases, and UI all talk about.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Equatable uses `props` to compare two Post instances by value,
  /// not by reference — so BLoC can detect actual state changes.
  @override
  List<Object> get props => [id, userId, title, body];
}
