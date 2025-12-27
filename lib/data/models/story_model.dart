class StoryLinkModel {
  final int id;
  final int storyId;
  final String youtubeLink;
  final String? linkTitle;
  final String? updatedAt;

  StoryLinkModel({
    required this.id,
    required this.storyId,
    required this.youtubeLink,
    this.linkTitle,
    this.updatedAt,
  });

  factory StoryLinkModel.fromApi(Map<String, dynamic> json) {
    return StoryLinkModel(
      id: json['id'] as int,
      storyId: json['story_id'] as int,
      youtubeLink: json['youtube_link'] as String,
      linkTitle: json['link_title'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  factory StoryLinkModel.fromDb(Map<String, dynamic> map) {
    return StoryLinkModel(
      id: map['id'] as int,
      storyId: map['story_id'] as int,
      youtubeLink: map['youtube_link'] as String,
      linkTitle: map['link_title'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'story_id': storyId,
      'youtube_link': youtubeLink,
      'link_title': linkTitle,
      'updated_at': updatedAt,
    };
  }
}

class StoryModel {
  final int id;
  final String storyTitle;
  final String? storyContent;
  final String? dateAdded;
  final String? updatedAt;
  final List<StoryLinkModel> links;

  StoryModel({
    required this.id,
    required this.storyTitle,
    this.storyContent,
    this.dateAdded,
    this.updatedAt,
    this.links = const [],
  });

  factory StoryModel.fromApi(Map<String, dynamic> json) {
    final linksJson = json['links'] as List<dynamic>? ?? [];
    return StoryModel(
      id: json['id'] as int,
      storyTitle: json['story_title'] as String,
      storyContent: json['story_content'] as String?,
      dateAdded: json['date_added'] as String?,
      updatedAt: json['updated_at'] as String?,
      links:
          linksJson
              .map(
                (item) => StoryLinkModel.fromApi(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  factory StoryModel.fromDb(
    Map<String, dynamic> map,
    List<StoryLinkModel> links,
  ) {
    return StoryModel(
      id: map['id'] as int,
      storyTitle: map['story_title'] as String,
      storyContent: map['story_content'] as String?,
      dateAdded: map['date_added'] as String?,
      updatedAt: map['updated_at'] as String?,
      links: links,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'story_title': storyTitle,
      'story_content': storyContent,
      'date_added': dateAdded,
      'updated_at': updatedAt,
    };
  }
}
