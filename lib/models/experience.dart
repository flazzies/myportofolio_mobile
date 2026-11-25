import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Portfolio experience synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    this.id,
    required this.title,
    required this.description,
    this.category = 'full-time',
    this.thumbnail,
    this.startedAt,
    this.endedAt,
    this.isOngoing,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String category;
  final String? thumbnail;
  final DateTime? startedAt;
  final DateTime? endedAt;

  // Property read-only dari Django (jangan ikut dikirim saat POST)
  @JsonKey(includeToJson: false)
  final bool? isOngoing;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
