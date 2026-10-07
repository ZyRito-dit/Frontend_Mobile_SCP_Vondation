import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/manage_history.dart';
import 'history_event.dart';
import 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory getHistory;
  final ClearHistory clearHistory;

  HistoryBloc({
    required this.getHistory,
    required this.clearHistory,
  }) : super(const HistoryState()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryLogsEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final list = await getHistory();
      emit(state.copyWith(status: HistoryStatus.success, history: list));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryLogsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    await clearHistory();
    add(LoadHistoryEvent());
  }
}
