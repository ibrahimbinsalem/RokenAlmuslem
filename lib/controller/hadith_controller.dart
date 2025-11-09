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
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. محاولة جلب الحديث من قاعدة البيانات المحلية أولاً لعرض سريع
      final Hadith? localHadith = await _dbHelper.getHadith();
      if (localHadith != null) {
        currentHadith.value = localHadith;
        isLoading.value = false; // عرض البيانات المحلية فوراً
      }

      // 2. محاولة جلب الحديث من الـ API في الخلفية لتحديث البيانات
      final Hadith? apiHadith = await _fetchHadithFromApi();

      if (apiHadith != null) {
        // 3. إذا نجح الجلب، قم بتحديث قاعدة البيانات والواجهة
        await _dbHelper.insertOrUpdateHadith(apiHadith);
        currentHadith.value = apiHadith;
      } else if (localHadith == null) {
        // 4. إذا فشل الجلب من الـ API ولم يكن هناك بيانات محلية
        errorMessage.value =
            'لم يتم العثور على حديث اليوم. يرجى التحقق من اتصالك بالإنترنت.';
      }
    } catch (e) {
      print("Error in _fetchHadith: $e");
      // إذا كان هناك خطأ وما زالت البيانات المحلية موجودة، اعرض رسالة خطأ غير مزعجة
      if (currentHadith.value != null) {
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
