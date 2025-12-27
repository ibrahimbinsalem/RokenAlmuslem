import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rokenalmuslem/data/models/story_model.dart';

class StoryDetailView extends StatelessWidget {
  const StoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final story = Get.arguments as StoryModel?;

    if (story == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: Text(
            'لا توجد بيانات للعرض',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: Text(
          story.storyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            story.storyContent ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          if (story.links.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'روابط الفيديو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(story.links.length, (index) {
                final url = story.links[index].youtubeLink;
                final title = story.links[index].linkTitle;
                final label =
                    (title != null && title.isNotEmpty)
                        ? title
                        : 'فيديو ${index + 1}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _openLink(context, url),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.tealAccent.withOpacity(0.4),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            color: Colors.tealAccent,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  url,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showLinkError(context);
      return;
    }

    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && context.mounted) {
      _showLinkError(context);
    }
  }

  void _showLinkError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعذر فتح الرابط.')),
    );
  }
}
