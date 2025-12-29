import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/app_rating_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class AppRatingView extends StatelessWidget {
  const AppRatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRatingController controller = Get.put(AppRatingController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: scheme.primary.withOpacity(0.85),
                  title: const Text('تقييم التطبيق'),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: controller.isLoggedIn
                        ? _buildRatingForm(context, controller)
                        : _buildLoginCard(context),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل الدخول للتقييم',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يلزم تسجيل الدخول لإرسال تقييمك وتعليقك.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoute.login),
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm(
    BuildContext context,
    AppRatingController controller,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.hasRating.value ? 'تم حفظ تقييمك' : 'قيّم تجربتك',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر عدد النجوم واكتب تعليقاً اختيارياً.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Row(
              children: List.generate(5, (index) {
                final value = index + 1;
                final isFilled = controller.rating.value >= value;
                return IconButton(
                  onPressed: () => controller.rating.value = value,
                  icon: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? scheme.primary : scheme.outline,
                    size: 32,
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: controller.commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب تعليقك هنا (اختياري)',
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    controller.isSubmitting.value ? null : controller.submitRating,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(controller.hasRating.value
                        ? 'تحديث التقييم'
                        : 'إرسال التقييم'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
