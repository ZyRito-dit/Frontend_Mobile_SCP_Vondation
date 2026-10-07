import '../../domain/entities/scp_item.dart';

class ScpItemModel extends ScpItem {
  const ScpItemModel({
    required super.scp,
    required super.title,
    required super.link,
    required super.rating,
    super.series,
    super.type,
    super.thumbnailUrl,
    super.timestamp,
    super.requiredClearance = 1,
  });

  factory ScpItemModel.fromJson(Map<String, dynamic> json) {
    return ScpItemModel(
      scp: json['scp']?.toString() ?? json['title'] ?? 'UNKNOWN',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      rating: (json['rating'] is int)
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      series: json['series']?.toString(),
      type: json['type']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      timestamp: json['timestamp'] ?? json['bookmarked_at'] ?? json['read_at'] ?? json['created_at'],
      requiredClearance: json['required_clearance'] is int
          ? json['required_clearance']
          : int.tryParse(json['required_clearance']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scp': scp,
      'title': title,
      'link': link,
      'rating': rating,
      'series': series,
      'type': type,
      'thumbnail_url': thumbnailUrl,
      'timestamp': timestamp,
      'required_clearance': requiredClearance,
    };
  }

  factory ScpItemModel.fromEntity(ScpItem entity) {
    return ScpItemModel(
      scp: entity.scp,
      title: entity.title,
      link: entity.link,
      rating: entity.rating,
      series: entity.series,
      type: entity.type,
      thumbnailUrl: entity.thumbnailUrl,
      timestamp: entity.timestamp,
      requiredClearance: entity.requiredClearance,
    );
  }
}
