import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/story_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/data/models/story_model.dart';

class StoriesView extends StatelessWidget {
  const StoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoriesController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text(
          'القصص',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stories.isEmpty) {
          return _buildEmptyState(
            message: controller.errorMessage.value.isEmpty
                ? 'لا توجد قصص بعد'
                : controller.errorMessage.value,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.syncStories(forceFull: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return _buildStoryCard(context, controller.stories[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: controller.stories.length,
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, size: 72, color: Colors.teal[200]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر القصص هنا بعد المزامنة.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryModel story) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoute.storyDetail, arguments: story),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              story.storyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              story.storyContent ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (story.links.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'عدد الروابط: ${story.links.length}',
                  style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
