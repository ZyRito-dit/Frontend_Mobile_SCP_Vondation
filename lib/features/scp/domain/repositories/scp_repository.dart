import '../entities/scp_item.dart';
import '../entities/scp_detail.dart';

abstract class ScpRepository {
  Future<Map<String, dynamic>> getArticles({int page = 1, String searchQuery = ''});
  Future<ScpDetail> getArticleDetail(String link);
  Future<List<ScpItem>> getBookmarks();
  Future<bool> isBookmarked(String scpId);
  Future<bool> toggleBookmark(ScpItem item);
  Future<List<ScpItem>> getHistory();
  Future<void> addToHistory(ScpItem item);
  Future<void> clearHistory();
}
