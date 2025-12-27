import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rokenalmuslem/core/functions/checkinternet.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';
import 'package:rokenalmuslem/data/datasourse/remote/story_remote.dart';
import 'package:rokenalmuslem/data/models/story_model.dart';

class StoriesController extends GetxController {
  final _remote = StoryRemote();
  final _db = DatabaseHelper.instance;

  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  static const String _lastSyncKey = 'stories_last_sync';

  @override
  void onInit() {
    super.onInit();
    _loadLocalStories();
    syncStories();
  }

  Future<void> _loadLocalStories() async {
    final localStories = await _db.getStories();
    stories.assignAll(localStories);
  }

  Future<void> syncStories({bool forceFull = false}) async {
    if (!await checkInternet()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = forceFull ? null : prefs.getString(_lastSyncKey);

      final remoteStories = await _remote.fetchStories(
        updatedAfter: lastSync,
      );

      if (remoteStories.isNotEmpty) {
        await _db.upsertStories(remoteStories);
        await _loadLocalStories();
      }

      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      errorMessage.value = 'تعذر تحديث البيانات. حاول مرة أخرى.';
    } finally {
      isLoading.value = false;
    }
  }
}
