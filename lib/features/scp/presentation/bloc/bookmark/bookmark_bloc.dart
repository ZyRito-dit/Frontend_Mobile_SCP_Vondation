import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/manage_bookmarks.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

@injectable
class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetBookmarks getBookmarks;
  final ToggleBookmark toggleBookmark;

  BookmarkBloc({
    required this.getBookmarks,
    required this.toggleBookmark,
  }) : super(const BookmarkState()) {
    on<LoadBookmarksEvent>(_onLoadBookmarks);
    on<RemoveBookmarkEvent>(_onRemoveBookmark);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarksEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      final list = await getBookmarks();
      emit(state.copyWith(status: BookmarkStatus.success, bookmarks: list));
    } catch (e) {
      emit(state.copyWith(status: BookmarkStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    await toggleBookmark(event.item);
    add(LoadBookmarksEvent());
  }
}
