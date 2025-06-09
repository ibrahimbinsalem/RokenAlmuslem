

// import 'package:baligne/core/class/statusrequist.dart';

// StatusRequist handelingData(response){
   
//    if(response is StatusRequist){
//       return response;
//    }else{
//     return StatusRequist.succes;
//    }
// }



import 'package:rokenalmuslem/core/class/statusrequist.dart';

/// دالة متطورة لمعالجة ردود API وتحويلها إلى StatusRequist
/// [response] يمكن أن تكون:
/// - null
/// - من نوع StatusRequist
/// - Map تحتوي على بيانات الاستجابة
StatusRequist handelingData(dynamic response) {
  // الحالة 1: إذا كانت الاستجابة فارغة
  if (response == null) {
    return StatusRequist.filuere;
  }

  // الحالة 2: إذا كانت الاستجابة بالفعل من نوع StatusRequist
  if (response is StatusRequist) {
    return response;
  }

  // الحالة 3: إذا كانت الاستجابة ليست خريطة (Map)
  if (response is! Map<String, dynamic>) {
    return StatusRequist.filuere;
  }

  // محاولة تحليل الاستجابة
  try {
    // الحالة 4: إذا كانت الاستجابة ناجحة
    if (response['status'] == 'success') {
      return StatusRequist.succes;
    }
    
    // الحالة 5: إذا كانت هناك أخطاء محددة
    final statusCode = response['statusCode'] ?? response['code'];
    
    switch (statusCode) {
      case 401:
        return StatusRequist.unauthorized;
      case 404:
        return StatusRequist.notFound;
      case 500:
      case 503:
        return StatusRequist.serverfilure;
      default:
        return StatusRequist.filuere;
    }
  } catch (e) {
    // الحالة 6: إذا حدث أي خطأ غير متوقع
    return StatusRequist.filuere;
  }
}