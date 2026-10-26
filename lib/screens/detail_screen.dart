import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/models/movie_detail.dart';
import 'package:movie_browser/providers/detail_provider.dart';
import 'package:movie_browser/providers/favorites_provider.dart';
import 'package:movie_browser/widgets/cast_tile.dart';
import 'package:movie_browser/widgets/error_view.dart';
import 'package:movie_browser/widgets/rating_badge.dart';

class DetailScreen extends ConsumerWidget {
  final int movieId;
  final Movie? initialMovie;

  const DetailScreen({super.key, required this.movieId, this.initialMovie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      body: detailAsync.when(
        data: (detail) => _DetailContent(detail: detail, isLoading: false),
        loading: () {
          if (initialMovie != null) {
            return _DetailContent(
              detail: MovieDetail.fromMovie(initialMovie!),
              isLoading: true,
            );
          }
          return _DetailSkeleton(movieId: movieId);
        },
        error: (error, _) {
          if (initialMovie != null) {
            return _DetailContent(
              detail: MovieDetail.fromMovie(initialMovie!),
              isLoading: false,
              errorMessage: error.toString(),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: error.toString(),
              onRetry: () => ref.refresh(movieDetailProvider(movieId)),
            ),
          );
        },
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final MovieDetail detail;
  final bool isLoading;
  final String? errorMessage;

  const _DetailContent({
    required this.detail,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isMovieFavoriteProvider(detail.id));
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          actions: [
            IconButton(
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                  ),
                  child: child,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? Colors.red : null,
                ),
              ),
              onPressed: () async {
                final added = await ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(detail.toMovie());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        added ? 'Added to favorites' : 'Removed from favorites',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (detail.backdropUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: detail.backdropUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 250),
                    fadeOutDuration: const Duration(milliseconds: 150),
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.movie_outlined, size: 50),
                    ),
                  )
                else
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.movie_outlined, size: 50),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(100),
                        Colors.transparent,
                        theme.colorScheme.surface.withAlpha(220),
                        theme.colorScheme.surface,
                      ],
                      stops: const [0.0, 0.4, 0.85, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'movie-poster-${detail.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 105,
                          height: 155,
                          child: detail.posterUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: detail.posterUrl,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                      const Duration(milliseconds: 250),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 150),
                                  placeholder: (context, url) => Container(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                )
                              : Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.movie),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (detail.releaseYear.isNotEmpty)
                                Text(
                                  detail.releaseYear,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (detail.releaseYear.isNotEmpty &&
                                  detail.runtimeFormatted.isNotEmpty)
                                const Text('•'),
                              if (detail.runtimeFormatted.isNotEmpty)
                                Text(
                                  detail.runtimeFormatted,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              RatingBadge(rating: detail.voteAverage),
                              const SizedBox(width: 6),
                              Text(
                                '/ 10',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (detail.genres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: detail.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ],
                if (detail.overview.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.overview,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (isLoading) ...[
                  const SizedBox(height: 20),
                  _buildShimmerBar(theme, width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  _buildShimmerBar(theme, width: 220, height: 16),
                ],
                if (detail.cast.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Top Cast',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: detail.cast.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return CastTile(cast: detail.cast[index]);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBar(
    ThemeData theme, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  final int movieId;

  const _DetailSkeleton({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: placeholderColor),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'movie-poster-$movieId',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 105,
                          height: 155,
                          color: placeholderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 24,
                            width: 160,
                            decoration: BoxDecoration(
                              color: placeholderColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 16,
                            width: 90,
                            decoration: BoxDecoration(
                              color: placeholderColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 240,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
