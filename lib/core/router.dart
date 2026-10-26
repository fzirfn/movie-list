import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/screens/detail_screen.dart';
import 'package:movie_browser/screens/favorites_screen.dart';
import 'package:movie_browser/screens/home_screen.dart';
import 'package:movie_browser/screens/search_screen.dart';
import 'package:movie_browser/screens/shell_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final initialMovie = state.extra is Movie ? state.extra as Movie : null;
        return CustomTransitionPage(
          key: state.pageKey,
          child: DetailScreen(movieId: id, initialMovie: initialMovie),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    ),
  ],
);
