import 'package:json_annotation/json_annotation.dart';

part 'list_story_response.g.dart';

@JsonSerializable()
class ListStoryResponse {
  final bool error;
  final String message;
  @JsonKey(name: "listStory")
  final List<ListStory> listStory;

  ListStoryResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory ListStoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ListStoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryResponseToJson(this);
}

@JsonSerializable()
class ListStory {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  ListStory({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory ListStory.fromJson(Map<String, dynamic> json) =>
      _$ListStoryFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryToJson(this);
}
