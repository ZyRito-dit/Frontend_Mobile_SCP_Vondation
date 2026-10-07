import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_item.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ScpItem> history;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.history = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<ScpItem>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, errorMessage];
}
