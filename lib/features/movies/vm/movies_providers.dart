import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core & data
import 'package:flutter_movies_portfolio/core/http_client.dart';
import 'package:flutter_movies_portfolio/features/movies/data/tmdb_api.dart';
import 'package:flutter_movies_portfolio/features/movies/data/movie_repository.dart';

// Models
import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie_details.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/actor.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/title_result.dart';

/// Clave (id + tipo) para los providers de detalle
class TitleKey {
  final int id;
  final MediaType type;
  const TitleKey(this.id, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TitleKey && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}

/// ----- Infraestructura -----
final httpClientProvider = Provider<HttpClient>((ref) => HttpClient());

final tmdbApiProvider = Provider<TmdbApi>(
  (ref) => TmdbApi(ref.watch(httpClientProvider)),
);

final movieRepoProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(ref.watch(tmdbApiProvider)),
);

/// ----- Estado de búsqueda -----
final searchQueryProvider = StateProvider<String>((_) => '');
final searchFilterProvider = StateProvider<MediaType>((_) => MediaType.movie);

/// ----- Listas Home -----
/// Películas populares
final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.watch(movieRepoProvider).getPopular();
});

/// Series populares (usamos Movie model: mapea name -> title)
final tvPopularProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.watch(movieRepoProvider).getTvPopular();
});

/// ----- Búsqueda -----
/// Solo películas
final searchedMoviesProvider = FutureProvider.autoDispose<List<Movie>>((
  ref,
) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return [];
  await Future<void>.delayed(const Duration(milliseconds: 250));
  return ref.watch(movieRepoProvider).searchMovies(q);
});

/// Solo series
final searchedTvProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return [];
  await Future<void>.delayed(const Duration(milliseconds: 250));
  return ref.watch(movieRepoProvider).searchTv(q);
});

/// Mixto (películas + series). Ignora personas.
final searchedAllProvider = FutureProvider.autoDispose<List<TitleResult>>((
  ref,
) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return [];
  await Future<void>.delayed(const Duration(milliseconds: 250));
  return ref.watch(movieRepoProvider).searchAll(q);
});

/// ----- Detalle (película/serie) -----
/// Detalle unificado por tipo
final titleDetailsProvider = FutureProvider.family<MovieDetails, TitleKey>((
  ref,
  key,
) async {
  final repo = ref.watch(movieRepoProvider);
  return key.type == MediaType.movie
      ? repo.getMovieDetails(key.id)
      : repo.getTvDetails(key.id);
});

/// Reparto unificado por tipo
final titleCastProvider = FutureProvider.family<List<Person>, TitleKey>((
  ref,
  key,
) async {
  final repo = ref.watch(movieRepoProvider);
  return key.type == MediaType.movie
      ? repo.getMovieCast(key.id)
      : repo.getTvCast(key.id);
});

/// Recomendaciones unificadas por tipo
final titleRecommendationsProvider =
    FutureProvider.family<List<Movie>, TitleKey>((ref, key) async {
      final repo = ref.watch(movieRepoProvider);
      return key.type == MediaType.movie
          ? repo.getMovieRecommendations(key.id)
          : repo.getTvRecommendations(key.id);
    });
