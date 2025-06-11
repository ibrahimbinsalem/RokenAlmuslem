// views/asma_allah_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rokenalmuslem/controller/more/asmaallacontroller.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/custom_asma_allah.dart'; // Adjust path as needed

class AsmaAllahView extends StatelessWidget {
  final AsmaAllahController _controller = Get.put(AsmaAllahController());

  AsmaAllahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "أسماء الله الحسنى",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
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
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: _controller.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0, // Ensures square items
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = _controller.items[index];
                  return CustomButtomAsmaAlah(
                    name: item["name"],
                    onTap: () {
                      _controller.showDescriptionBottomSheet(
                        context,
                        item["name"],
                        item["dis"],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
