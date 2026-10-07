import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/get_scp_articles.dart';
import 'scp_list_event.dart';
import 'scp_list_state.dart';

@injectable
class ScpListBloc extends Bloc<ScpListEvent, ScpListState> {
  final GetScpArticles getScpArticles;

  ScpListBloc(this.getScpArticles) : super(const ScpListState()) {
    on<FetchScpArticlesEvent>(_onFetchArticles);
    on<SearchScpArticlesEvent>(_onSearchArticles);
  }

  Future<void> _onFetchArticles(
    FetchScpArticlesEvent event,
    Emitter<ScpListState> emit,
  ) async {
    if (!state.hasMore && !event.isRefresh) return;

    if (event.isRefresh || state.status == ScpListStatus.initial) {
      emit(state.copyWith(
        status: ScpListStatus.loading,
        currentPage: 1,
        articles: [],
        hasMore: true,
      ));
    }

    try {
      final pageToFetch = event.isRefresh ? 1 : state.currentPage;
      final result = await getScpArticles(
        page: pageToFetch,
        searchQuery: state.searchQuery,
      );

      final newArticles = result['data'] as List;
      final nextPageUrl = result['next_page_url'];

      final updatedList = event.isRefresh
          ? List.of(newArticles)
          : (List.of(state.articles)..addAll(newArticles.cast()));

      emit(state.copyWith(
        status: ScpListStatus.success,
        articles: updatedList.cast(),
        hasMore: nextPageUrl != null && newArticles.isNotEmpty,
        currentPage: pageToFetch + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScpListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchArticles(
    SearchScpArticlesEvent event,
    Emitter<ScpListState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
      articles: [],
      hasMore: true,
      status: ScpListStatus.loading,
    ));

    add(const FetchScpArticlesEvent(isRefresh: true));
  }
}
