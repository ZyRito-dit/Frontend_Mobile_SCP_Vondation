import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_item.dart';

abstract class ScpDetailEvent extends Equatable {
  const ScpDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchScpDetailEvent extends ScpDetailEvent {
  final String link;
  final String title;

  const FetchScpDetailEvent({required this.link, required this.title});

  @override
  List<Object?> get props => [link, title];
}

class ToggleBookmarkDetailEvent extends ScpDetailEvent {
  final ScpItem item;

  const ToggleBookmarkDetailEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class TranslateScpDetailEvent extends ScpDetailEvent {}
