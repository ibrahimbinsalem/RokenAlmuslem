// import 'package:eco_store/controller/auth/signup_controller.dart';

import 'package:rokenalmuslem/core/class/crud.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:rokenalmuslem/view/screen/home/homepage.dart';

class InitialBindings extends Bindings{
  @override
  void dependencies() {
      Get.lazyPut( ()=> HomePage() , fenix: true);
        Get.put(Crud());


  }

}