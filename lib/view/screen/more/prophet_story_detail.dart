import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rokenalmuslem/data/models/prophet_story_model.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class ProphetStoryDetailView extends StatelessWidget {
  const ProphetStoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final story = Get.arguments as ProphetStoryModel?;
    final scheme = Theme.of(context).colorScheme;

    if (story == null) {
      return Scaffold(
        backgroundColor: scheme.background,
        body: Center(
          child: Text(
            'لا توجد بيانات للعرض',
            style: TextStyle(color: scheme.onSurface),
          ),
        ),
      );
    }

    return ModernScaffold(
      title: story.prophetName,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            story.storyContent ?? '',
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          if (story.links.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: scheme.onSurface.withOpacity(0.12)),
            const SizedBox(height: 12),
            Text(
              'روابط الفيديو',
              style: TextStyle(
                color: scheme.onSurface,
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
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: scheme.primary.withOpacity(0.25),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: scheme.primary,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  url,
                                  style: TextStyle(
                                    color: scheme.onSurface.withOpacity(0.6),
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
