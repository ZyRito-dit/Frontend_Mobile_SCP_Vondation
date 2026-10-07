import 'package:equatable/equatable.dart';

class ScpDetail extends Equatable {
  final String scp;
  final String title;
  final int rating;
  final String? series;
  final String rawContent;
  final String? translatedTitle;
  final String? translatedContent;
  final int requiredClearance;

  const ScpDetail({
    required this.scp,
    required this.title,
    required this.rating,
    this.series,
    required this.rawContent,
    this.translatedTitle,
    this.translatedContent,
    this.requiredClearance = 1,
  });

  @override
  List<Object?> get props => [
        scp,
        title,
        rating,
        series,
        rawContent,
        translatedTitle,
        translatedContent,
        requiredClearance,
      ];
}
