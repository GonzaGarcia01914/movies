class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String releaseDate;
  final double voteAverage;

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: json['id'] as int,
    title: json['title'] as String? ?? json['name'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    releaseDate: json['release_date'] as String? ?? '',
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  );

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
}
