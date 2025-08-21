import 'package:flutter_movies_portfolio/features/movies/data/models/actor.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie_details.dart';
import 'package:flutter_movies_portfolio/features/movies/data/tmdb_api.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/title_result.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';

class MovieRepository {
  final TmdbApi api;
  MovieRepository(this.api);

  Future<List<Movie>> getPopular({int page = 1}) async {
    final json = await api.popular(page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Movie.fromJson).toList();
  }

  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final json = await api.nowPlaying(page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Movie.fromJson).toList();
  }

  Future<List<Movie>> search(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final json = await api.search(query, page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Movie.fromJson).toList();
  }

  Future<MovieDetails> getMovieDetails(int id) async {
    final j = await api.movieDetails(id);
    return MovieDetails.fromJson(j);
  }

  Future<List<Person>> getMovieCast(int id) async {
    final j = await api.movieCredits(id);
    final cast = (j['cast'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return cast.map(Person.fromJson).toList();
  }

  Future<List<Movie>> getMovieRecommendations(int id, {int page = 1}) async {
    final j = await api.movieRecommendations(id, page: page);
    final results =
        (j['results'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return results.map(Movie.fromJson).toList(); // Movie ya mapea title/name
  }

  Future<List<Movie>> getTvPopular({int page = 1}) async {
    final j = await api.tvPopular(page: page);
    final results =
        (j['results'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return results.map(Movie.fromJson).toList();
  }

  Future<MovieDetails> getTvDetails(int id) async =>
      MovieDetails.fromJson(await api.tvDetails(id));

  Future<List<Person>> getTvCast(int id) async {
    final j = await api.tvCredits(id);
    final cast = (j['cast'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return cast.map(Person.fromJson).toList();
  }

  Future<List<Movie>> getTvRecommendations(int id, {int page = 1}) async {
    final j = await api.tvRecommendations(id, page: page);
    final results =
        (j['results'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return results.map(Movie.fromJson).toList(); // usa 'name'→title
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final json = await api.search(query, page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Movie.fromJson).toList();
  }

  Future<List<Movie>> searchTv(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final json = await api.searchTv(query, page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Movie.fromJson).toList();
  }

  Future<List<TitleResult>> searchAll(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final json = await api.searchMulti(query, page: page);
    final results = (json['results'] as List).cast<Map<String, dynamic>>();

    final out = <TitleResult>[];
    for (final r in results) {
      final media = (r['media_type'] as String?) ?? '';
      if (media == 'movie') {
        out.add(TitleResult(Movie.fromJson(r), MediaType.movie));
      } else if (media == 'tv') {
        out.add(TitleResult(Movie.fromJson(r), MediaType.tv));
      }
    }
    return out;
  }
}
