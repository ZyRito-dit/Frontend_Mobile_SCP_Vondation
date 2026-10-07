import 'package:equatable/equatable.dart';

class ScpItem extends Equatable {
  final String scp;
  final String title;
  final String link;
  final int rating;
  final String? series;
  final String? type;
  final String? thumbnailUrl;
  final String? timestamp;
  final int requiredClearance;

  const ScpItem({
    required this.scp,
    required this.title,
    required this.link,
    required this.rating,
    this.series,
    this.type,
    this.thumbnailUrl,
    this.timestamp,
    this.requiredClearance = 1,
  });

  @override
  List<Object?> get props => [
        scp,
        title,
        link,
        rating,
        series,
        type,
        thumbnailUrl,
        timestamp,
        requiredClearance,
      ];
}
