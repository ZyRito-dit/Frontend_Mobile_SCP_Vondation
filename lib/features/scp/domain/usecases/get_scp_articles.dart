import 'package:injectable/injectable.dart';
import '../repositories/scp_repository.dart';

@lazySingleton
class GetScpArticles {
  final ScpRepository repository;

  GetScpArticles(this.repository);

  Future<Map<String, dynamic>> call({int page = 1, String searchQuery = ''}) async {
    return await repository.getArticles(page: page, searchQuery: searchQuery);
  }
}
