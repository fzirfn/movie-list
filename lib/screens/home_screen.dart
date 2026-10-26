import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/providers/movies_provider.dart';
import 'package:movie_browser/widgets/empty_view.dart';
import 'package:movie_browser/widgets/error_view.dart';
import 'package:movie_browser/widgets/loading_grid.dart';
import 'package:movie_browser/widgets/movie_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
          ],
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            MovieGridTab(
              provider: trendingMoviesProvider,
              onRefresh: () =>
                  ref.read(trendingMoviesProvider.notifier).refresh(),
              onLoadMore: () =>
                  ref.read(trendingMoviesProvider.notifier).loadNextPage(),
            ),
            MovieGridTab(
              provider: popularMoviesProvider,
              onRefresh: () =>
                  ref.read(popularMoviesProvider.notifier).refresh(),
              onLoadMore: () =>
                  ref.read(popularMoviesProvider.notifier).loadNextPage(),
            ),
            MovieGridTab(
              provider: topRatedMoviesProvider,
              onRefresh: () =>
                  ref.read(topRatedMoviesProvider.notifier).refresh(),
              onLoadMore: () =>
                  ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieGridTab extends ConsumerStatefulWidget {
  final NotifierProvider<dynamic, PaginatedMoviesState> provider;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const MovieGridTab({
    super.key,
    required this.provider,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  ConsumerState<MovieGridTab> createState() => _MovieGridTabState();
}

class _MovieGridTabState extends ConsumerState<MovieGridTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(widget.provider);

    Widget body;
    if (state.isLoading && state.movies.isEmpty) {
      body = const LoadingGrid(key: ValueKey('loading_grid'));
    } else if (state.errorMessage != null && state.movies.isEmpty) {
      body = ErrorView(
        key: const ValueKey('error_view'),
        message: state.errorMessage!,
        onRetry: widget.onRefresh,
      );
    } else if (state.movies.isEmpty) {
      body = RefreshIndicator(
        key: const ValueKey('empty_view'),
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyView(
              title: 'No Movies Found',
              message: 'Check back later for updated movie lists.',
            ),
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        key: const ValueKey('movie_grid'),
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
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
                  final movie = state.movies[index];
                  return MovieCard(movie: movie);
                }, childCount: state.movies.length),
              ),
            ),
            if (state.isLoading && state.movies.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              ),
            if (state.errorMessage != null && state.movies.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: widget.onLoadMore,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Failed to load more. Tap to retry'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: body,
    );
  }
}
