import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/mainscreencontroller.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';

class CosmicNavBar extends StatelessWidget {
  const CosmicNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenControllerImp>();
    final notificationsController = Get.find<NotificationsController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? scheme.surface : scheme.surface;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            barColor.withOpacity(0.96),
            barColor.withOpacity(0.99),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.18),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withOpacity(0),
                    scheme.primary.withOpacity(0.45),
                    scheme.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildNavItem(
                Icons.mosque_outlined,
                Icons.mosque,
                "الرئيسية",
                0,
                controller,
                theme,
              ),
              _buildNavItem(
                Icons.menu_book_outlined,
                Icons.menu_book,
                "المصحف",
                1,
                controller,
                theme,
              ),
              Obx(() {
                return _buildNavItem(
                  Icons.notifications_outlined,
                  Icons.notifications,
                  "الرسائل",
                  2,
                  controller,
                  theme,
                  badgeCount: notificationsController.unreadCount.value,
                  pulse: notificationsController.pulseUnread.value,
                );
              }),
              _buildNavItem(
                Icons.menu_book_outlined,
                Icons.menu_book,
                "أذكار المسلم",
                3,
                controller,
                theme,
              ),
              _buildNavItem(
                Icons.more_vert_outlined,
                Icons.more_vert,
                "المزيد",
                4,
                controller,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    int index,
    MainScreenControllerImp controller,
    ThemeData theme,
    {
      int badgeCount = 0,
      bool pulse = false,
    }
  ) {
    final isActive = controller.curentpage == index;
    final iconSize = 28.0;
    final scheme = theme.colorScheme;
    final showBadge = badgeCount > 0;
    final badgeText = badgeCount > 9 ? '9+' : badgeCount.toString();

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: scheme.primary.withOpacity(0.2),
          highlightColor: Colors.transparent,
          onTap: () => controller.changePage(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isActive ? 50 : 40,
                width: isActive ? 50 : 40,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            scheme.primary.withOpacity(0.25),
                            scheme.secondary.withOpacity(0.12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showBadge && pulse)
                      Positioned(
                        top: 4,
                        right: 10,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.6),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: 1 - (value - 0.8) / 0.8,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.secondary.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isActive)
                      Positioned(
                        top: 5,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: scheme.secondary.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    Icon(
                      isActive ? filledIcon : outlineIcon,
                      size: iconSize,
                      color: isActive
                          ? scheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    if (showBadge)
                      Positioned(
                        top: 2,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.error.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            badgeText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 14 : 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? scheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                child: Text(label),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: scheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.secondary.withOpacity(0.6),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
