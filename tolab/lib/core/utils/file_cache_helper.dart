import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FileCacheHelper {
  static final BaseCacheManager _cacheManager = DefaultCacheManager();

  /// تحميل الملف مع الكاش
  static Future<String> getFilePath(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);

    if (fileInfo != null) {
      // موجود في الكاش
      return fileInfo.file.path;
    } else {
      // نحمله ونخزنه
      final downloadedFile = await _cacheManager.getSingleFile(url);
      return downloadedFile.path;
    }
  }

  /// مسح كاش مادة معينة
  static Future<void> removeFromCache(String url) async {
    await _cacheManager.removeFile(url);
  }

  /// مسح كل الكاش
  static Future<void> clearAllCache() async {
    await _cacheManager.emptyCache();
  }
}
