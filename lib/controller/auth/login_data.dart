import 'package:rokenalmuslem/core/class/crud.dart';
import 'package:rokenalmuslem/linkapi.dart';

class LoginData {
  Crud crud;

  LoginData() : crud = Crud();

  postData(String email, String password) async {
    var response = await crud.postData(AppLink.login, {
      "email": email,
      "password": password,
    });
    return response; // **تعديل: إرجاع كائن Either مباشرة**
  }

  postFirebase(String idToken) async {
    var response = await crud.postData(AppLink.firebaseLogin, {
      "id_token": idToken,
    });
    return response;
  }
}
