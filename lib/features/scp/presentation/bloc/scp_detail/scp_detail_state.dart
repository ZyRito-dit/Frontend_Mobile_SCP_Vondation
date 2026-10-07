import 'package:equatable/equatable.dart';
import '../../../domain/entities/scp_detail.dart';

enum ScpDetailStatus { initial, loading, success, failure }

class ScpDetailState extends Equatable {
  final ScpDetailStatus status;
  final ScpDetail? detail;
  final bool isBookmarked;
  final bool isTranslating;
  final bool isTranslated;
  final String? translatedTitle;
  final String? translatedContent;
  final String? errorMessage;

  const ScpDetailState({
    this.status = ScpDetailStatus.initial,
    this.detail,
    this.isBookmarked = false,
    this.isTranslating = false,
    this.isTranslated = false,
    this.translatedTitle,
    this.translatedContent,
    this.errorMessage,
  });

  ScpDetailState copyWith({
    ScpDetailStatus? status,
    ScpDetail? detail,
    bool? isBookmarked,
    bool? isTranslating,
    bool? isTranslated,
    String? translatedTitle,
    String? translatedContent,
    String? errorMessage,
  }) {
    return ScpDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isTranslating: isTranslating ?? this.isTranslating,
      isTranslated: isTranslated ?? this.isTranslated,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedContent: translatedContent ?? this.translatedContent,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detail,
        isBookmarked,
        isTranslating,
        isTranslated,
        translatedTitle,
        translatedContent,
        errorMessage,
      ];
}
