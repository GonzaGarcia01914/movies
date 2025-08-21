class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;

  MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) => MovieDetails(
    id: json['id'] as int,
    title: (json['title'] as String?) ?? (json['name'] as String?) ?? '',
    overview: json['overview'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    backdropPath: json['backdrop_path'] as String?,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  );

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
}
