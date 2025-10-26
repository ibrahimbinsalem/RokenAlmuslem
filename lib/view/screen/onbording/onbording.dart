import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/onbordingcontroller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/services.dart'; // تأكد من استيراد MyServices
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBordiding extends StatefulWidget {
  @override
  _OnBordidingState createState() => _OnBordidingState();
}

class _OnBordidingState extends State<OnBordiding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true; // متغير الحالة للتحكم في ظهور شاشة التحميل

  @override
  void initState() {
    super.initState();
    _loadData(); // استدعاء دالة لتحميل البيانات (محاكاة)
  }

  Future<void> _loadData() async {
    // محاكاة عملية تحميل البيانات
    // في التطبيق الحقيقي، هنا يمكنك جلب أي بيانات ضرورية قبل عرض شاشة الترحيب
    await Future.delayed(Duration(seconds: 2)); // انتظار لمدة ثانيتين

    // بعد الانتهاء من التحميل، قم بتعيين isLoading إلى false لعرض المحتوى الرئيسي
    if (mounted) {
      // التأكد من أن الودجت لا يزال في الشجرة قبل setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تهيئة OnBordingControllerImpl
    OnBordingControllerImpl controller = Get.put(OnBordingControllerImpl());

    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8F5F0), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // مؤشر التحميل (يظهر فقط إذا كان _isLoading صحيحًا)
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "جاري تحميل البينات الى التطبيق...", // نص التحميل
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF2E7D32),
                      fontFamily: 'Amiri', // افتراض أنك تستخدم هذا الخط
                    ),
                  ),
                ],
              ),
            )
          else // عرض المحتوى الرئيسي بمجرد اكتمال التحميل
          // كل المحتوى الذي يستخدم Positioned أو يحتاج إلى أن يكون مكدسًا
          // يجب أن يكون مباشرة ضمن قائمة children الخاصة بـ Stack الخارجي.
          ...[
            // PageView.builder (الآن مباشرة ضمن Stack الخارجي)
            PageView.builder(
              controller: _pageController,
              itemCount: controller.onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 70),

                        // زر التخطي (يظهر فقط في الصفحتين الأولى والثانية)
                        if (index <
                            controller.onboardingData.length -
                                1) // يظهر حتى قبل الأخيرة
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                _pageController.animateToPage(
                                  controller.onboardingData.length -
                                      1, // الذهاب إلى الصفحة الأخيرة
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Text(
                                "تخطي",
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 40),

                        // الصورة التوضيحية
                        Container(
                          height: 280,
                          child: Image.asset(
                            controller.onboardingData[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: 50),

                        // العنوان
                        Text(
                          controller.onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 28,

                            color: Color(0xFF2E7D32),
                          ),
                        ),

                        SizedBox(height: 25),

                        // النص الفرعي
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            controller.onboardingData[index]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                );
              },
            ),

            // مؤشر الصفحات (مباشرة ضمن Stack الخارجي)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: controller.onboardingData.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    activeDotColor: Color(0xFF2E7D32),
                    dotColor: Colors.grey[300]!,
                    spacing: 8,
                  ),
                ),
              ),
            ),

            // زر البدء (يظهر فقط في الصفحة الأخيرة، مباشرة ضمن Stack الخارجي)
            if (_currentPage == controller.onboardingData.length - 1)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      // تعيين علامة 'hasSeenOnboarding' إلى true لإشارة إلى اكتمال الترحيب
                      // يتم الوصول إلى MyServices عبر Get.find() بعد تهيئتها في main.dart
                      MyServices myServices = Get.find();
                      await myServices.sharedprf.setString("step", "1");
                      // الانتقال إلى الصفحة الرئيسية وإزالة جميع المسارات السابقة
                      Get.offAllNamed(AppRoute.homePage);
                    },
                    child: Text(
                      "ابدأ الآن",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
