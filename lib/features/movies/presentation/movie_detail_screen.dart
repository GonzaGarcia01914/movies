import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_movies_portfolio/features/movies/vm/movies_providers.dart';
import 'package:flutter_movies_portfolio/features/movies/presentation/widgets/movie_small_card.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int titleId;
  final MediaType mediaType;
  const MovieDetailScreen({
    super.key,
    required this.titleId,
    this.mediaType = MediaType.movie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TitleKey(titleId, mediaType);
    final details = ref.watch(titleDetailsProvider(key));
    final cast = ref.watch(titleCastProvider(key));
    final recs = ref.watch(titleRecommendationsProvider(key));

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2A),
        title: const Text('Details'),
      ),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Error(text: 'Error loading details: $e'),
        data: (d) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                title: d.title,
                rating: d.voteAverage,
                posterUrl: d.posterUrl,
                backdropUrl: d.backdropUrl,
              ),
            ),
            if (d.overview.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    d.overview,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            // Reparto
            const SliverToBoxAdapter(child: _SectionTitle('Cast')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: cast.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Error(text: 'Error: $e'),
                  data: (people) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: people.length.clamp(0, 20),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final p = people[i];
                      return _CastCard(
                        name: p.name,
                        role: p.character ?? '',
                        imgUrl: p.profileUrl,
                      );
                    },
                  ),
                ),
              ),
            ),
            // Recomendaciones
            const SliverToBoxAdapter(child: _SectionTitle('Recomendations')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 230,
                child: recs.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Error(text: 'Error: $e'),
                  data: (items) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length.clamp(0, 20),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) =>
                        MovieSmallCard(movie: items[i], mediaType: mediaType),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final double rating;
  final String posterUrl;
  final String backdropUrl;

  const _Header({
    required this.title,
    required this.rating,
    required this.posterUrl,
    required this.backdropUrl,
  });

  Color _ratingColor(double v) {
    if (v >= 7.0) return Colors.greenAccent;
    if (v >= 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (rating / 10).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (backdropUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(backdropUrl, fit: BoxFit.cover),
          ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 170,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: posterUrl.isNotEmpty
                        ? Image.network(posterUrl, fit: BoxFit.cover)
                        : Container(color: const Color(0xFF243655)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Título + Rating circular
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 26.0,
                          lineWidth: 6.0,
                          percent: percent,
                          center: Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: _ratingColor(rating),
                          backgroundColor: Colors.white10,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Rating',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final String name;
  final String role;
  final String imgUrl;
  const _CastCard({
    required this.name,
    required this.role,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              child: imgUrl.isNotEmpty
                  ? Image.network(imgUrl, fit: BoxFit.cover)
                  : Container(color: const Color(0xFF243655)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            role,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String text;
  const _Error({required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
