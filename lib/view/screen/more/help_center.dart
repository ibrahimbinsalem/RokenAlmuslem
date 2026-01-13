import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/help_center_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final HelpCenterController controller = Get.put(HelpCenterController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = width > 620 ? 560.0 : width;

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: width * 0.04,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, scheme),
                            const SizedBox(height: 20),
                            _buildSupportStatusCard(
                              context,
                              controller,
                              scheme,
                            ),
                            const SizedBox(height: 18),
                            _buildSupportRating(
                              context,
                              controller,
                              scheme,
                            ),
                            const SizedBox(height: 18),
                            _buildArchiveSection(
                              context,
                              controller,
                              scheme,
                            ),
                            const SizedBox(height: 18),
                            _buildFaqSection(context, controller),
                            const SizedBox(height: 18),
                            _buildSupportAction(context, scheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.92),
            scheme.secondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز المساعدة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نساعدك في كل ما يتعلق بالتطبيق والخدمة.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportStatusCard(
    BuildContext context,
    HelpCenterController controller,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);

    if (!controller.isLoggedIn) {
      return _buildLoginPrompt(context, scheme);
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(scheme),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final thread = controller.thread.value;
      if (thread == null) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(scheme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لا توجد محادثة مفتوحة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ محادثة جديدة وسنقوم بالرد عليك بأقرب وقت.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoute.supportChat),
                icon: const Icon(Icons.support_agent),
                label: const Text('ابدأ المحادثة'),
              ),
            ],
          ),
        );
      }

      final statusLabel = thread.status == 'closed' ? 'مغلقة' : 'مفتوحة';
      final statusColor =
          thread.status == 'closed' ? scheme.error : scheme.primary;
      final lastUpdate = thread.lastMessageAt;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(scheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'الحالة: $statusLabel',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (lastUpdate != null)
                  Text(
                    _formatDate(lastUpdate),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaChip(
                  context,
                  scheme,
                  Icons.folder_outlined,
                  'التصنيف: ${_categoryLabel(thread.category)}',
                ),
                if (thread.lastSenderType.trim().isNotEmpty)
                  _buildMetaChip(
                    context,
                    scheme,
                    thread.lastSenderType == 'admin'
                        ? Icons.support_agent_outlined
                        : Icons.person_outline,
                    thread.lastSenderType == 'admin'
                        ? 'آخر رد: فريق الدعم'
                        : 'آخر رد: أنت',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (thread.lastMessagePreview.trim().isNotEmpty)
              Text(
                thread.lastMessagePreview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              )
            else
              Text(
                'آخر رسالة بدون معاينة.',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoute.supportChat),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('فتح المحادثة'),
                ),
                if (thread.status == 'open')
                  Obx(() {
                    final isClosing = controller.isClosingThread.value;
                    return ElevatedButton.icon(
                      onPressed: isClosing
                          ? null
                          : () => _confirmCloseThread(context, controller),
                      icon: isClosing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('إغلاق المحادثة'),
                    );
                  }),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSupportRating(
    BuildContext context,
    HelpCenterController controller,
    ColorScheme scheme,
  ) {
    if (!controller.isLoggedIn) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Obx(() {
      final thread = controller.thread.value;
      if (thread == null) {
        return const SizedBox.shrink();
      }

      if (thread.status != 'closed') {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(scheme),
          child: Row(
            children: [
              Icon(Icons.star_border, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'يمكنك تقييم الدعم بعد إغلاق المحادثة.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        );
      }

      final rating = controller.supportRating.value;
      final createdAt = rating?.createdAt;
      final isSubmitting = controller.isSubmittingRating.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(scheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقييم تجربة الدعم',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'آخر تقييم: ${_formatDate(createdAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: List.generate(
                5,
                (index) {
                  final value = index + 1;
                  final isSelected = controller.ratingValue.value >= value;
                  return InkWell(
                    onTap: () => controller.ratingValue.value = value,
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color:
                          isSelected ? scheme.primary : scheme.outlineVariant,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.ratingCommentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك حول تجربة الدعم (اختياري)',
                filled: true,
                fillColor: scheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ElevatedButton.icon(
                onPressed:
                    isSubmitting ? null : () => controller.submitRating(),
                icon: isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(rating == null ? 'إرسال التقييم' : 'تحديث التقييم'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildArchiveSection(
    BuildContext context,
    HelpCenterController controller,
    ColorScheme scheme,
  ) {
    if (!controller.isLoggedIn) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Obx(() {
      final items = controller.archivedThreads;
      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(scheme),
          child: Row(
            children: [
              Icon(Icons.archive_outlined, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'لا توجد محادثات سابقة مؤرشفة حتى الآن.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: _cardDecoration(scheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أرشيف المحادثات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((thread) {
              final date = thread.lastMessageAt ?? thread.updatedAt;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'محادثة #${thread.id}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (date != null)
                          Text(
                            _formatDate(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      thread.lastMessagePreview.trim().isEmpty
                          ? 'تم إغلاق المحادثة.'
                          : thread.lastMessagePreview,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildMetaChip(
                          context,
                          scheme,
                          Icons.folder_outlined,
                          _categoryLabel(thread.category),
                        ),
                        _buildMetaChip(
                          context,
                          scheme,
                          Icons.lock_outline,
                          'مغلقة',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoute.supportChat,
                          arguments: {
                            'thread_id': thread.id,
                            'read_only': true,
                          },
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('عرض المحادثة'),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildFaqSection(
    BuildContext context,
    HelpCenterController controller,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Obx(() {
      final items = controller.faqItems;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: _cardDecoration(scheme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الأسئلة الشائعة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                'لا توجد أسئلة شائعة متاحة حالياً.',
                style: theme.textTheme.bodySmall,
              )
            else
              ...items.map(
                (item) => Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      item.question,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          item.answer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSupportAction(BuildContext context, ColorScheme scheme) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(scheme),
      child: Row(
        children: [
          Icon(Icons.headset_mic, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'هل تحتاج إلى مساعدة مباشرة؟ افتح محادثة مع فريق الدعم.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoute.supportChat),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('تواصل الآن'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ColorScheme scheme) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجّل الدخول لمتابعة حالة رسائلك',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عند تسجيل الدخول يمكنك متابعة حالة محادثتك مع الدعم.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoute.login),
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surface.withOpacity(0.95),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: scheme.primary.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Future<void> _confirmCloseThread(
    BuildContext context,
    HelpCenterController controller,
  ) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إغلاق المحادثة'),
          content: const Text(
            'هل تريد إغلاق محادثة الدعم؟ يمكنك فتحها لاحقًا بإرسال رسالة جديدة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.closeThread();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text('تأكيد الإغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetaChip(
    BuildContext context,
    ColorScheme scheme,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'account':
        return 'الحساب';
      case 'technical':
        return 'تقني';
      case 'content':
        return 'المحتوى';
      case 'suggestion':
        return 'اقتراحات';
      case 'other':
        return 'أخرى';
      default:
        return 'عام';
    }
  }

  String _formatDate(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month ${hours}:$minutes';
  }
}
