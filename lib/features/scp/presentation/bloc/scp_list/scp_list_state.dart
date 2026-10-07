import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_item.dart';

enum ScpListStatus { initial, loading, success, failure }

class ScpListState extends Equatable {
  final ScpListStatus status;
  final List<ScpItem> articles;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;
  final String? errorMessage;

  const ScpListState({
    this.status = ScpListStatus.initial,
    this.articles = const [],
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery = '',
    this.errorMessage,
  });

  ScpListState copyWith({
    ScpListStatus? status,
    List<ScpItem>? articles,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ScpListState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        hasMore,
        currentPage,
        searchQuery,
        errorMessage,
      ];
}
