import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/providers/favorites_provider.dart';
import 'package:movie_browser/widgets/empty_view.dart';
import 'package:movie_browser/widgets/movie_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    Widget content;
    if (favorites.isEmpty) {
      content = const EmptyView(
        key: ValueKey('favorites_empty'),
        title: 'No Favorites Yet',
        message: 'Tap the heart icon on any movie to add it to your favorites.',
        icon: Icons.favorite_border_rounded,
      );
    } else {
      content = CustomScrollView(
        key: const ValueKey('favorites_grid'),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final movie = favorites[index];
                return MovieCard(
                  movie: movie,
                  onRemove: () {
                    ref.read(favoritesProvider.notifier).removeFavorite(movie.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Removed from favorites'),
                      ),
                    );
                  },
                );
              }, childCount: favorites.length),
            ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: content,
    );
  }
}
