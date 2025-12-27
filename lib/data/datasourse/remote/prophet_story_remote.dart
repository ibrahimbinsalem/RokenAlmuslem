import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rokenalmuslem/data/models/prophet_story_model.dart';
import 'package:rokenalmuslem/linkapi.dart';

class ProphetStoryRemote {
  Future<List<ProphetStoryModel>> fetchStories({String? updatedAfter}) async {
    final uri = Uri.parse(AppLink.prophetStories).replace(
      queryParameters:
          updatedAfter == null ? null : {'updated_after': updatedAfter},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load prophet stories.');
    }

    final Map<String, dynamic> body = json.decode(response.body);
    if (body['status'] != 'success') {
      return [];
    }

    final List<dynamic> data = body['data'] as List<dynamic>;
    return data
        .map(
          (item) => ProphetStoryModel.fromApi(item as Map<String, dynamic>),
        )
        .toList();
  }
}
