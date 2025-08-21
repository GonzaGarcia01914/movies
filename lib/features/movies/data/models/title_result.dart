import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';

class TitleResult {
  final Movie movie;
  final MediaType type;
  const TitleResult(this.movie, this.type);
}
