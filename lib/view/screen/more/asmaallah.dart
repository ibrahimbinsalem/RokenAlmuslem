// views/asma_allah_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rokenalmuslem/controller/more/asmaallacontroller.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/custom_asma_allah.dart'; // Adjust path as needed
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AsmaAllahView extends StatelessWidget {
  final AsmaAllahController _controller = Get.put(AsmaAllahController());

  AsmaAllahView({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: "أسماء الله الحسنى",
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // Ensure this image exists
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          GetX<AsmaAllahController>(
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  itemCount: controller.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0, // Ensures square items
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return CustomButtomAsmaAlah(
                      name: item["name"],
                      onTap: () {
                        controller.showDescriptionBottomSheet(
                          context,
                          item["name"],
                          item["dis"],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
