import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/prophet_story_controller.dart';
import 'package:rokenalmuslem/data/models/prophet_story_model.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class ProphetStoriesView extends StatelessWidget {
  const ProphetStoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProphetStoriesController());
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'قصص الأنبياء',
      extendBodyBehindAppBar: false,
      body: GetX<ProphetStoriesController>(
        builder: (controller) {
          if (controller.isLoading.value && controller.stories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.stories.isEmpty) {
            return _buildEmptyState(
              scheme: scheme,
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
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required ColorScheme scheme,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 72,
              color: scheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر قصص الأنبياء هنا بعد المزامنة.',
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, ProphetStoryModel story) {
    final scheme = Theme.of(context).colorScheme;
    final links = story.links.map((link) => link.youtubeLink).toList();
    return InkWell(
      onTap: () => Get.toNamed(AppRoute.prophetStoryDetail, arguments: story),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              story.prophetName,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              story.storyContent ?? '',
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (links.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'عدد الروابط: ${links.length}',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
