import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// VM (providers)
import 'package:flutter_movies_portfolio/features/movies/vm/movies_providers.dart';

// Widgets
import 'package:flutter_movies_portfolio/features/movies/presentation/widgets/movie_big_card.dart';
import 'package:flutter_movies_portfolio/features/movies/presentation/widgets/movie_small_card.dart';
import 'package:flutter_movies_portfolio/features/movies/presentation/widgets/drag_scroll_row.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/title_result.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final searchAsync = ref.watch(searchedMoviesProvider);
    final moviesAsync = ref.watch(popularMoviesProvider);
    final tvAsync = ref.watch(tvPopularProvider);
    final isSearching = query.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2A),
        elevation: 0,
        titleSpacing: 12,
        title: _SearchBar(
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(popularMoviesProvider);
            ref.invalidate(tvPopularProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: isSearching
              ? _SearchSection(searchAsync: searchAsync)
              : _HomeSections(moviesAsync: moviesAsync, tvAsync: tvAsync),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF162238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _SearchSection extends ConsumerWidget {
  final AsyncValue<List<dynamic>> searchAsync;
  const _SearchSection({required this.searchAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);

    final async = switch (filter) {
      MediaType.movie => ref.watch(searchedMoviesProvider),
      MediaType.tv => ref.watch(searchedTvProvider),
      MediaType.all => ref.watch(searchedAllProvider),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips de filtro
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Movies'),
                selected: filter == MediaType.movie,
                onSelected: (_) =>
                    ref.read(searchFilterProvider.notifier).state =
                        MediaType.movie,
              ),
              ChoiceChip(
                label: const Text('Series'),
                selected: filter == MediaType.tv,
                onSelected: (_) =>
                    ref.read(searchFilterProvider.notifier).state =
                        MediaType.tv,
              ),
              ChoiceChip(
                label: const Text('All'),
                selected: filter == MediaType.all,
                onSelected: (_) =>
                    ref.read(searchFilterProvider.notifier).state =
                        MediaType.all,
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            data: (items) {
              final results = switch (filter) {
                MediaType.all => (items as List<TitleResult>),
                MediaType.movie =>
                  (items as List<Movie>)
                      .map((m) => TitleResult(m, MediaType.movie))
                      .toList(),
                MediaType.tv =>
                  (items as List<Movie>)
                      .map((m) => TitleResult(m, MediaType.tv))
                      .toList(),
              };

              if (results.isEmpty) {
                return const _EmptyMessage('No results');
              }

              return Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: results.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (_, i) {
                    final r = results[i];

                    return MovieBigCard(movie: r.movie, mediaType: r.type);
                  },
                ),
              );
            },
            loading: () => const _LoadingGrid(),
            error: (e, _) => _ErrorLabel(message: e.toString()),
          ),
        ),
      ],
    );
  }
}

class _HomeSections extends StatelessWidget {
  final AsyncValue<List<dynamic>> moviesAsync;
  final AsyncValue<List<dynamic>> tvAsync;
  const _HomeSections({required this.moviesAsync, required this.tvAsync});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 12, right: 0, top: 12, bottom: 24),
      children: [
        const _SectionTitle(title: 'Movies'),
        SizedBox(
          height: 390,
          child: moviesAsync.when(
            data: (movies) => DragScrollRow(
              itemCount: movies.length,
              itemBuilder: (_, i) => MovieBigCard(movie: movies[i]),
            ),
            loading: () => const _LoadingRow(itemWidth: 220, height: 390),
            error: (e, _) => _ErrorLabel(message: e.toString()),
          ),
        ),
        const SizedBox(height: 8),
        const _SectionTitle(title: 'Series'),
        SizedBox(
          height: 230,
          child: tvAsync.when(
            data: (series) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 12),
              itemBuilder: (_, i) =>
                  MovieSmallCard(movie: series[i], mediaType: MediaType.tv),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: series.length,
            ),
            loading: () => const _LoadingRow(itemWidth: 130, height: 230),
            error: (e, _) => _ErrorLabel(message: e.toString()),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ErrorLabel extends StatelessWidget {
  final String message;
  const _ErrorLabel({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Ups: $message',
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String text;
  const _EmptyMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  final double itemWidth;
  final double height;
  const _LoadingRow({required this.itemWidth, required this.height});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 12),
      itemBuilder: (_, __) =>
          _ShimmerBox(width: itemWidth, height: height - 40, radius: 16),
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemCount: 5,
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (_, __) => const _ShimmerBox(
          width: double.infinity,
          height: double.infinity,
          radius: 16,
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  late final Animation<double> _a = Tween(
    begin: 0.2,
    end: 0.5,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF1A2B48),
            const Color(0xFF22365B),
            _a.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
