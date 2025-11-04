import 'package:rokenalmuslem/core/class/crud.dart';

class TestData {
  Crud crud;
  TestData(this.crud);

  addData(Map<String, dynamic> data) async {
    var response = await crud.postData("", data);

    return response.fold((l) => l, (r) => r);
  }

  getServices() async {
    var response = await crud.postData("", {});

    return response.fold((l) => l, (r) => r);
  }

  getReportType(Map<String, dynamic> data) async {
    var response = await crud.postData("", data);

    return response.fold((l) => l, (r) => r);
  }
}
