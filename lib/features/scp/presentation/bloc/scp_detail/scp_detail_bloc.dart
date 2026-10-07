import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:translator/translator.dart';
import '../../../domain/entities/scp_item.dart';
import '../../../domain/usecases/get_scp_detail.dart';
import '../../../domain/usecases/manage_bookmarks.dart';
import '../../../domain/usecases/manage_history.dart';
import 'scp_detail_event.dart';
import 'scp_detail_state.dart';

@injectable
class ScpDetailBloc extends Bloc<ScpDetailEvent, ScpDetailState> {
  final GetScpDetail getScpDetail;
  final IsBookmarked checkIsBookmarked;
  final ToggleBookmark toggleBookmark;
  final AddToHistory addToHistory;
  final translator = GoogleTranslator();

  ScpDetailBloc({
    required this.getScpDetail,
    required this.checkIsBookmarked,
    required this.toggleBookmark,
    required this.addToHistory,
  }) : super(const ScpDetailState()) {
    on<FetchScpDetailEvent>(_onFetchDetail);
    on<ToggleBookmarkDetailEvent>(_onToggleBookmark);
    on<TranslateScpDetailEvent>(_onTranslateDetail);
  }

  Future<void> _onFetchDetail(
    FetchScpDetailEvent event,
    Emitter<ScpDetailState> emit,
  ) async {
    emit(state.copyWith(status: ScpDetailStatus.loading));

    try {
      final detail = await getScpDetail(event.link);
      final bookmarked = await checkIsBookmarked(event.link);

      // Record to History
      await addToHistory(
        ScpItem(
          scp: detail.scp,
          title: event.title,
          link: event.link,
          rating: detail.rating,
          series: detail.series,
          requiredClearance: detail.requiredClearance,
        ),
      );

      emit(state.copyWith(
        status: ScpDetailStatus.success,
        detail: detail,
        isBookmarked: bookmarked,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScpDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkDetailEvent event,
    Emitter<ScpDetailState> emit,
  ) async {
    final updatedStatus = await toggleBookmark(event.item);
    emit(state.copyWith(isBookmarked: updatedStatus));
  }

  Future<void> _onTranslateDetail(
    TranslateScpDetailEvent event,
    Emitter<ScpDetailState> emit,
  ) async {
    if (state.detail == null) return;

    if (state.isTranslated) {
      emit(state.copyWith(isTranslated: false));
      return;
    }

    if (state.translatedContent != null) {
      emit(state.copyWith(isTranslated: true));
      return;
    }

    emit(state.copyWith(isTranslating: true));

    try {
      final tTitle = await translator.translate(state.detail!.title, from: 'en', to: 'id');
      String rawHtml = state.detail!.rawContent;

      List<String> chunks = rawHtml.split(RegExp(r'(?=<(p|div|blockquote)>)'));
      String translatedHtml = '';

      for (String chunk in chunks) {
        if (chunk.trim().isEmpty) continue;
        if (chunk.length > 5) {
          try {
            var t = await translator.translate(chunk, from: 'en', to: 'id');
            translatedHtml += t.text;
          } catch (_) {
            translatedHtml += chunk;
          }
        } else {
          translatedHtml += chunk;
        }
      }

      emit(state.copyWith(
        isTranslating: false,
        isTranslated: true,
        translatedTitle: tTitle.text,
        translatedContent: translatedHtml,
      ));
    } catch (e) {
      emit(state.copyWith(
        isTranslating: false,
        errorMessage: 'Gagal terjemah: $e',
      ));
    }
  }
}
