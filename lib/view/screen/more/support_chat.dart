import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/support_chat_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportChatView extends StatelessWidget {
  const SupportChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportChatController controller = Get.put(SupportChatController());
    controller.applyArguments();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, controller, scheme),
              Expanded(
                child: controller.isLoggedIn
                    ? Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.messages.isEmpty) {
                          return _buildEmptyState(context, controller, scheme);
                        }

                        return RefreshIndicator(
                          onRefresh: controller.refreshMessages,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: controller.messages.length,
                            itemBuilder: (context, index) {
                              final message = controller.messages[index];
                              final isUser = message.senderType == 'user';
                        return _buildBubble(
                          context,
                          message.message,
                          message.createdAt,
                          isUser,
                          attachmentUrl: message.attachmentUrl,
                          attachmentType: message.attachmentType,
                          attachmentName: message.attachmentName,
                        );
                      },
                    ),
                  );
                      })
                    : _buildLoginCard(context),
              ),
              controller.isLoggedIn
                  ? controller.readOnly
                      ? _buildArchiveFooter(context)
                      : _buildInputBar(context, controller)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SupportChatController controller,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);
    final isArchived = controller.readOnly;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.95),
            scheme.secondary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تواصل مع الإدارة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'نرد على استفساراتك واقتراحاتك باهتمام',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderStatus(context, isArchived),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArchived
                        ? 'هذه المحادثة مؤرشفة، ويمكنك بدء محادثة جديدة متى شئت.'
                        : 'عادةً ما يتم الرد خلال 24 ساعة بحد أقصى.',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatus(BuildContext context, bool isArchived) {
    final theme = Theme.of(context);
    final label = isArchived ? 'أرشيف' : 'نشطة';
    final icon = isArchived ? Icons.lock_outline : Icons.circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    SupportChatController controller,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.primary.withOpacity(0.15),
              child: Icon(Icons.chat_bubble_outline, color: scheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ محادثتك الأولى',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أرسل سؤالك أو ملاحظتك وسنقوم بالمتابعة معك.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              controller.readOnly
                  ? 'المحادثة مؤرشفة ويمكنك بدء محادثة جديدة.'
                  : 'اكتب رسالتك في الأسفل للبدء.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سجل الدخول للمراسلة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يلزم تسجيل الدخول للتواصل مع إدارة التطبيق.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoute.login),
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(
    BuildContext context,
    String message,
    DateTime timestamp,
    bool isUser,
    {
      String? attachmentUrl,
      String? attachmentType,
      String? attachmentName,
    }
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxWidth = MediaQuery.of(context).size.width * 0.74;
    final hasAttachment =
        attachmentUrl != null && attachmentUrl.trim().isNotEmpty;
    final isImage = attachmentType?.startsWith('image/') ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primary.withOpacity(0.12),
              child: Icon(
                Icons.support_agent,
                size: 18,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  color: isUser ? scheme.primary : scheme.surface,
                  gradient: isUser
                      ? LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: isUser
                      ? null
                      : Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Text(
                        'فريق الدعم',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (!isUser) const SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : scheme.onSurface,
                      ),
                    ),
                    if (hasAttachment) ...[
                      const SizedBox(height: 10),
                      if (isImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            attachmentUrl!,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: scheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: scheme.primary,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        InkWell(
                          onTap: () => _openAttachment(attachmentUrl!),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 18,
                                color: isUser ? Colors.white : scheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  attachmentName ?? 'تحميل المرفق',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        isUser ? Colors.white : scheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 6),
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        _formatTime(timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              isUser ? Colors.white70 : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.primary.withOpacity(0.18),
              child: Icon(
                Icons.person,
                size: 16,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    SupportChatController controller,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final file = controller.selectedAttachment.value;
            if (file == null) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.clearAttachment,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.primary.withOpacity(0.2)),
                ),
                child: IconButton(
                  onPressed: controller.pickAttachment,
                  icon: Icon(
                    Icons.attach_file,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.inputController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك هنا',
                    filled: true,
                    fillColor: scheme.surfaceVariant.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: controller.isSending.value
                        ? null
                        : controller.sendMessage,
                    icon: controller.isSending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveFooter(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.archive_outlined, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'هذه المحادثة مؤرشفة للعرض فقط.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Get.toNamed(AppRoute.supportChat),
            child: const Text('محادثة جديدة'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
