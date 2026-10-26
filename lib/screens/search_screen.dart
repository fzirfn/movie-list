import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/providers/search_provider.dart';
import 'package:movie_browser/widgets/empty_view.dart';
import 'package:movie_browser/widgets/error_view.dart';
import 'package:movie_browser/widgets/loading_grid.dart';
import 'package:movie_browser/widgets/movie_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      ref.read(searchProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchBar(
            controller: _textController,
            hintText: 'Search movies by title...',
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search_rounded),
            ),
            trailing: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _textController.text.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear_search'),
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _textController.clear();
                          ref.read(searchProvider.notifier).clear();
                          setState(() {});
                        },
                      )
                    : const SizedBox.shrink(key: ValueKey('clear_empty')),
              ),
            ],
            onChanged: (value) {
              ref.read(searchProvider.notifier).onQueryChanged(value);
              setState(() {});
            },
            elevation: const WidgetStatePropertyAll(1),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildBody(searchState, theme),
      ),
    );
  }

  Widget _buildBody(SearchState state, ThemeData theme) {
    if (!state.hasSearched || state.query.isEmpty) {
      return const EmptyView(
        key: ValueKey('search_hint'),
        title: 'Search for Movies',
        message: 'Type a title above to discover movies from TMDB.',
        icon: Icons.search_rounded,
      );
    }

    if (state.isLoading && state.movies.isEmpty) {
      return const LoadingGrid(key: ValueKey('search_loading'));
    }

    if (state.errorMessage != null && state.movies.isEmpty) {
      return ErrorView(
        key: const ValueKey('search_error'),
        message: state.errorMessage!,
        onRetry: () => ref.read(searchProvider.notifier).search(state.query),
      );
    }

    if (state.movies.isEmpty) {
      return EmptyView(
        key: const ValueKey('search_no_results'),
        title: 'No Movies Found',
        message:
            'No movies found matching "${state.query}". Try a different keyword.',
        icon: Icons.search_off_rounded,
      );
    }

    return CustomScrollView(
      key: const ValueKey('search_results'),
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
                  onPressed: () =>
                      ref.read(searchProvider.notifier).loadNextPage(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Failed to load more. Tap to retry'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
