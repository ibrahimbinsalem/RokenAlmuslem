import 'package:rokenalmuslem/core/class/crud.dart';
import 'package:rokenalmuslem/linkapi.dart';

class SignUpData {
  Crud crud;

  SignUpData(this.crud);

  postData(String username, String email, String password) async {
    var response = await crud.postData(AppLink.signUp, {
      "name": username,
      "email": email,
      "password": password,
    });
    return response; // **تصحيح: إرجاع كائن Either مباشرة**
  }
}
