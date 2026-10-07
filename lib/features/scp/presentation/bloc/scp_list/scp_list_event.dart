import 'package:equatable/equatable.dart';

abstract class ScpListEvent extends Equatable {
  const ScpListEvent();

  @override
  List<Object?> get props => [];
}

class FetchScpArticlesEvent extends ScpListEvent {
  final bool isRefresh;
  const FetchScpArticlesEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchScpArticlesEvent extends ScpListEvent {
  final String query;
  const SearchScpArticlesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
