import 'package:flutter/material.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';
import 'package:flutter_movies_portfolio/features/movies/presentation/movie_detail_screen.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';

class MovieBigCard extends StatelessWidget {
  final Movie movie;
  final MediaType mediaType;
  const MovieBigCard({
    super.key,
    required this.movie,
    this.mediaType = MediaType.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    MovieDetailScreen(titleId: movie.id, mediaType: mediaType),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // opcional si usas la card también en la grilla de búsqueda
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(movie.posterUrl, fit: BoxFit.cover)
                      : Container(color: const Color(0xFF243655)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
