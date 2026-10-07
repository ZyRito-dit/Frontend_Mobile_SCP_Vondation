import 'package:injectable/injectable.dart';
import '../entities/scp_item.dart';
import '../repositories/scp_repository.dart';

@lazySingleton
class GetHistory {
  final ScpRepository repository;
  GetHistory(this.repository);

  Future<List<ScpItem>> call() async {
    return await repository.getHistory();
  }
}

@lazySingleton
class AddToHistory {
  final ScpRepository repository;
  AddToHistory(this.repository);

  Future<void> call(ScpItem item) async {
    await repository.addToHistory(item);
  }
}

@lazySingleton
class ClearHistory {
  final ScpRepository repository;
  ClearHistory(this.repository);

  Future<void> call() async {
    await repository.clearHistory();
  }
}
