import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static const key = 'customCacheKey';
  static final customCacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
