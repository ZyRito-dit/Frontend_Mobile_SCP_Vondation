import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_item.dart';

enum BookmarkStatus { initial, loading, success, failure }

class BookmarkState extends Equatable {
  final BookmarkStatus status;
  final List<ScpItem> bookmarks;
  final String? errorMessage;

  const BookmarkState({
    this.status = BookmarkStatus.initial,
    this.bookmarks = const [],
    this.errorMessage,
  });

  BookmarkState copyWith({
    BookmarkStatus? status,
    List<ScpItem>? bookmarks,
    String? errorMessage,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookmarks, errorMessage];
}
