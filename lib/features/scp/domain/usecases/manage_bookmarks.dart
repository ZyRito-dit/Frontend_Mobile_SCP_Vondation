import 'package:injectable/injectable.dart';
import '../entities/scp_item.dart';
import '../repositories/scp_repository.dart';

@lazySingleton
class GetBookmarks {
  final ScpRepository repository;
  GetBookmarks(this.repository);

  Future<List<ScpItem>> call() async {
    return await repository.getBookmarks();
  }
}

@lazySingleton
class ToggleBookmark {
  final ScpRepository repository;
  ToggleBookmark(this.repository);

  Future<bool> call(ScpItem item) async {
    return await repository.toggleBookmark(item);
  }
}

@lazySingleton
class IsBookmarked {
  final ScpRepository repository;
  IsBookmarked(this.repository);

  Future<bool> call(String scpId) async {
    return await repository.isBookmarked(scpId);
  }
}
