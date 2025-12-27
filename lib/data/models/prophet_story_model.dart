class ProphetStoryLinkModel {
  final int id;
  final int storyId;
  final String youtubeLink;
  final String? linkTitle;
  final String? updatedAt;

  ProphetStoryLinkModel({
    required this.id,
    required this.storyId,
    required this.youtubeLink,
    this.linkTitle,
    this.updatedAt,
  });

  factory ProphetStoryLinkModel.fromApi(Map<String, dynamic> json) {
    return ProphetStoryLinkModel(
      id: json['id'] as int,
      storyId: json['story_id'] as int,
      youtubeLink: json['youtube_link'] as String,
      linkTitle: json['link_title'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  factory ProphetStoryLinkModel.fromDb(Map<String, dynamic> map) {
    return ProphetStoryLinkModel(
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

class ProphetStoryModel {
  final int id;
  final String prophetName;
  final String? storyContent;
  final String? dateAdded;
  final String? updatedAt;
  final List<ProphetStoryLinkModel> links;

  ProphetStoryModel({
    required this.id,
    required this.prophetName,
    this.storyContent,
    this.dateAdded,
    this.updatedAt,
    this.links = const [],
  });

  factory ProphetStoryModel.fromApi(Map<String, dynamic> json) {
    final linksJson = json['links'] as List<dynamic>? ?? [];
    return ProphetStoryModel(
      id: json['id'] as int,
      prophetName: json['prophet_name'] as String,
      storyContent: json['story_content'] as String?,
      dateAdded: json['date_added'] as String?,
      updatedAt: json['updated_at'] as String?,
      links:
          linksJson
              .map(
                (item) => ProphetStoryLinkModel.fromApi(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  factory ProphetStoryModel.fromDb(
    Map<String, dynamic> map,
    List<ProphetStoryLinkModel> links,
  ) {
    return ProphetStoryModel(
      id: map['id'] as int,
      prophetName: map['prophet_name'] as String,
      storyContent: map['story_content'] as String?,
      dateAdded: map['date_added'] as String?,
      updatedAt: map['updated_at'] as String?,
      links: links,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'prophet_name': prophetName,
      'story_content': storyContent,
      'date_added': dateAdded,
      'updated_at': updatedAt,
    };
  }
}
