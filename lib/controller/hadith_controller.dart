import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/hadith_model.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';

class HadithController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Dio _dio = Dio();

  // متغيرات الحالة
  final Rx<Hadith?> currentHadith = Rx<Hadith?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final String _apiUrl =
      'https://tasks.arabwaredos.com/rouknalmuslam/hadyttoday/view.php';

  @override
  void onInit() {
    super.onInit();
    _fetchHadith();
  }

  Future<void> _fetchHadith() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. محاولة جلب الحديث من الـ API
      final Hadith? apiHadith = await _fetchHadithFromApi();

      if (apiHadith != null) {
        // 2. إذا نجح الجلب، قم بتحديث قاعدة البيانات والواجهة
        await _dbHelper.insertOrUpdateHadith(apiHadith);
        currentHadith.value = apiHadith;
      } else {
        // 3. إذا فشل الجلب من الـ API، حاول جلب الحديث من قاعدة البيانات المحلية
        final Hadith? localHadith = await _dbHelper.getHadith();
        if (localHadith != null) {
          currentHadith.value = localHadith;
        } else {
          // 4. إذا لم يوجد حديث في الـ API أو قاعدة البيانات
          errorMessage.value = 'لم يتم العثور على حديث اليوم.';
        }
      }
    } catch (e) {
      // في حالة حدوث أي خطأ، حاول التحميل من قاعدة البيانات كحل بديل
      print("Error in _fetchHadith: $e");
      final Hadith? localHadith = await _dbHelper.getHadith();
      if (localHadith != null) {
        currentHadith.value = localHadith;
        errorMessage.value = 'فشل الاتصال، تم عرض آخر حديث محفوظ.';
      } else {
        errorMessage.value =
            'فشل تحميل الحديث. يرجى التحقق من اتصالك بالإنترنت.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Hadith?> _fetchHadithFromApi() async {
    try {
      final response = await _dio.get(_apiUrl);

      if (response.statusCode == 200 && response.data != null) {
        // 1. تحليل الاستجابة الرئيسية
        final Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = json.decode(response.data) as Map<String, dynamic>;
        } else {
          responseData = response.data as Map<String, dynamic>;
        }

        // 2. الوصول إلى قائمة 'data' داخل الاستجابة
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> hadithList = responseData['data'];

          // 3. التأكد من أن القائمة ليست فارغة وأخذ أول عنصر
          if (hadithList.isNotEmpty) {
            final Map<String, dynamic> hadithData = hadithList.first;
            return Hadith.fromJson(hadithData);
          }
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch hadith from API: $e');
      return null; // إرجاع null للإشارة إلى فشل الاتصال
    }
  }

  // دالة لتحديث الحديث يدويًا
  Future<void> refreshHadith() async {
    await _fetchHadith();
  }
}
