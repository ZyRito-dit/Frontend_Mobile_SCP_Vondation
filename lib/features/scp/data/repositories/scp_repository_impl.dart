import 'package:injectable/injectable.dart';
import '../../domain/entities/scp_item.dart';
import '../../domain/entities/scp_detail.dart';
import '../../domain/repositories/scp_repository.dart';
import '../datasources/scp_remote_data_source.dart';
import '../datasources/scp_local_data_source.dart';
import '../models/scp_item_model.dart';

@LazySingleton(as: ScpRepository)
class ScpRepositoryImpl implements ScpRepository {
  final ScpRemoteDataSource remoteDataSource;
  final ScpLocalDataSource localDataSource;

  ScpRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> getArticles({int page = 1, String searchQuery = ''}) async {
    final rawData = await remoteDataSource.fetchArticles(page: page, searchQuery: searchQuery);
    final List<dynamic> listJson = rawData['data'] ?? [];
    final items = listJson.map((json) => ScpItemModel.fromJson(json)).toList();

    return {
      'data': items,
      'next_page_url': rawData['next_page_url'],
    };
  }

  @override
  Future<ScpDetail> getArticleDetail(String link) async {
    return await remoteDataSource.fetchArticleDetail(link);
  }

  @override
  Future<List<ScpItem>> getBookmarks() async {
    return await localDataSource.getBookmarks();
  }

  @override
  Future<bool> isBookmarked(String scpId) async {
    return await localDataSource.isBookmarked(scpId);
  }

  @override
  Future<bool> toggleBookmark(ScpItem item) async {
    return await localDataSource.toggleBookmark(ScpItemModel.fromEntity(item));
  }

  @override
  Future<List<ScpItem>> getHistory() async {
    return await localDataSource.getHistory();
  }

  @override
  Future<void> addToHistory(ScpItem item) async {
    await localDataSource.addToHistory(ScpItemModel.fromEntity(item));
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}
