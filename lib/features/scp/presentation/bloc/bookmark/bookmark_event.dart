import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_item.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarksEvent extends BookmarkEvent {}

class RemoveBookmarkEvent extends BookmarkEvent {
  final ScpItem item;
  const RemoveBookmarkEvent(this.item);

  @override
  List<Object?> get props => [item];
}
