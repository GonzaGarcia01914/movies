import '../../../core/env.dart';
import '../../../core/http_client.dart';

class TmdbApi {
  final HttpClient client;
  TmdbApi(this.client);

  Uri _build(String path, [Map<String, String>? extra]) {
    final q = <String, String>{'language': Env.lang, ...?extra};
    return Uri.parse('${Env.baseUrl}$path').replace(queryParameters: q);
  }

  Future<Map<String, dynamic>> popular({int page = 1}) =>
      client.getJson(_build('/movie/popular', {'page': '$page'}));
  Future<Map<String, dynamic>> nowPlaying({int page = 1}) =>
      client.getJson(_build('/movie/now_playing', {'page': '$page'}));

  Future<Map<String, dynamic>> search(String query, {int page = 1}) =>
      client.getJson(
        _build('/search/movie', {
          'query': query,
          'include_adult': 'false',
          'page': '$page',
        }),
      );

  Future<Map<String, dynamic>> movieDetails(int id) =>
      client.getJson(_build('/movie/$id'));

  Future<Map<String, dynamic>> movieCredits(int id) =>
      client.getJson(_build('/movie/$id/credits'));

  Future<Map<String, dynamic>> movieRecommendations(int id, {int page = 1}) =>
      client.getJson(_build('/movie/$id/recommendations', {'page': '$page'}));

  Future<Map<String, dynamic>> tvPopular({int page = 1}) =>
      client.getJson(_build('/tv/popular', {'page': '$page'}));

  Future<Map<String, dynamic>> tvDetails(int id) =>
      client.getJson(_build('/tv/$id'));

  Future<Map<String, dynamic>> tvCredits(int id) =>
      client.getJson(_build('/tv/$id/credits'));

  Future<Map<String, dynamic>> tvRecommendations(int id, {int page = 1}) =>
      client.getJson(_build('/tv/$id/recommendations', {'page': '$page'}));

  Future<Map<String, dynamic>> searchTv(String query, {int page = 1}) =>
      client.getJson(
        _build('/search/tv', {
          'query': query,
          'include_adult': 'false',
          'page': '$page',
        }),
      );

  Future<Map<String, dynamic>> searchMulti(String query, {int page = 1}) =>
      client.getJson(
        _build('/search/multi', {
          'query': query,
          'include_adult': 'false',
          'page': '$page',
        }),
      );
}
