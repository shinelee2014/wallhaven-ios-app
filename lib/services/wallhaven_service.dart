import 'package:dio/dio.dart';
import '../models/wallpaper.dart';

class WallhavenService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://wallhaven.cc/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  String? apiKey;

  WallhavenService({this.apiKey});

  Future<List<Wallpaper>> getWallpapers({
    String? q,
    String? categories, // e.g. "111" for general/anime/people
    String? purity, // e.g. "100" for SFW
    String? sorting, // "date_added", "relevance", "random", "views", "favorites", "toplist"
    String? order, // "desc", "asc"
    String? toplistRange, // "1d", "3d", "1w", "1M", "3M", "6M", "1y"
    int page = 1,
    String? colors,
    String? ratios,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      if (q != null) 'q': q,
      if (categories != null) 'categories': categories,
      if (purity != null) 'purity': purity,
      if (sorting != null) 'sorting': sorting,
      if (order != null) 'order': order,
      if (toplistRange != null && sorting == 'toplist') 'toplist_range': toplistRange,
      if (apiKey != null) 'apikey': apiKey,
      if (colors != null) 'colors': colors,
      if (ratios != null) 'ratios': ratios,
    };

    try {
      final response = await _dio.get('/search', queryParameters: queryParameters);
      final List data = response.data['data'];
      return data.map((json) => Wallpaper.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load wallpapers: $e');
    }
  }

  Future<Wallpaper> getWallpaperDetails(String id) async {
    try {
      final response = await _dio.get('/w/$id', queryParameters: {
        if (apiKey != null) 'apikey': apiKey,
      });
      return Wallpaper.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load wallpaper details: $e');
    }
  }
}
