import 'package:flutter/material.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/movie.dart';
import 'package:flutter_movies_portfolio/features/movies/data/models/media_type.dart';
import 'package:flutter_movies_portfolio/features/movies/presentation/movie_detail_screen.dart';

class MovieSmallCard extends StatelessWidget {
  final Movie movie;
  final MediaType mediaType;

  const MovieSmallCard({
    super.key,
    required this.movie,
    this.mediaType = MediaType.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          //side: const BorderSide(color: Color(0x22FFFFFF)),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: movie.posterUrl.isNotEmpty
                    ? Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(color: const Color(0xFF243655)),
              ),

              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
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
