import 'package:injectable/injectable.dart';
import '../entities/scp_detail.dart';
import '../repositories/scp_repository.dart';

@lazySingleton
class GetScpDetail {
  final ScpRepository repository;

  GetScpDetail(this.repository);

  Future<ScpDetail> call(String link) async {
    return await repository.getArticleDetail(link);
  }
}
