import 'package:get/get.dart';
import 'package:rokenalmuslem/core/services/services.dart';

translateDatabase(columnar , columnen){
 MyServices myServices = Get.find();
   
  if(myServices.sharedprf.getString("lang") == "ar"){
    return columnar;
  }else{
      return columnen;
  }
}