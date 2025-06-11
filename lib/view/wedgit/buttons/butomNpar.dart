import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/mainscreencontroller.dart';
import 'package:rokenalmuslem/core/constant/color.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/custom_tetx.dart';

class CosmicNavBar extends StatelessWidget {
  const CosmicNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenControllerImp>();
    final size = MediaQuery.of(context).size;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorsApp.appbar.withOpacity(0.95),
            ColorsApp.appbar.withOpacity(0.98),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsApp.primer.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // تأثير الضوء السفلي
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsApp.primer.withOpacity(0),
                    ColorsApp.primer.withOpacity(0.7),
                    ColorsApp.primer.withOpacity(0),
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
                size,
              ),
              _buildNavItem(
                Icons.notifications_outlined,
                Icons.notifications,
                "الرسائل",
                1,
                controller,
                size,
              ),
              _buildNavItem(
                Icons.menu_book_outlined,
                Icons.menu_book,
                "أذكار المسلم",
                2,
                controller,
                size,
              ),
              _buildNavItem(
                Icons.more_vert_outlined,
                Icons.more_vert,
                "المزيد",
                3,
                controller,
                size,
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
    Size size,
  ) {
    final isActive = controller.curentpage == index;
    final iconSize = 28.0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: ColorsApp.primer.withOpacity(0.2),
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
                  gradient:
                      isActive
                          ? LinearGradient(
                            colors: [
                              Colors.greenAccent.withValues(alpha: 0.3),
                              Colors.greenAccent.withValues(alpha: 0.1),
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
                    if (isActive)
                      Positioned(
                        top: 5,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent,
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
                      color: isActive ? Colors.greenAccent : Colors.grey[400],
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
                  color: isActive ? Colors.greenAccent : Colors.grey[400],
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
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent,
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
