import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:path/path.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/functions/checkinternet.dart';

String _basicAuth = 'Basic ' + base64Encode(utf8.encode('ibrahim:Shadow7000'));

Map<String, String> myheaders = {'authorization': _basicAuth};

class Crud {
  Future<Either<StatusRequist, Map>> postData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        var response = await http.post(
          Uri.parse(linkurl),
          body: data,
          headers: myheaders,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);

          return Right(responsebody);
        } else {
          return const Left(StatusRequist.serverfilure);
        }
      } else {
        return Left(StatusRequist.offlinefilure);
      }
    } catch (e) {
      print(e);
      return const Left(StatusRequist.serverExiption);
    }
  }

  Future<Either<StatusRequist, Map>> getData(String linkurl) async {
    try {
      if (await checkInternet()) {
        var response = await http.get(Uri.parse(linkurl), headers: myheaders);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);

          return Right(responsebody);
        } else {
          return const Left(StatusRequist.serverfilure);
        }
      } else {
        return Left(StatusRequist.offlinefilure);
      }
    } catch (e) {
      print(e);
      return const Left(StatusRequist.serverExiption);
    }
  }

  // Uplod Image whit requist :

  Future<Either<StatusRequist, Map>> postFile(
    url,
    data,
    File? image, [
    String? namerequest,
  ]) async {
    if (namerequest == null) {
      namerequest = "file";
    }

    print("Crud.postFile: Preparing request...");
    print("  URL: $url");
    print("  Data fields: $data");
    print("  File parameter name (namerequest): $namerequest");

    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);
    request.headers.addAll(myheaders);

    if (image != null) {
      var length = await image.length();
      var stream = http.ByteStream(image.openRead());
      stream.cast();
      var multipartFile = http.MultipartFile(
        namerequest,
        stream,
        length,
        filename: basename(image.path),
      );
      request.files.add(multipartFile);
      print("  MultipartFile created:");
      print("    Field Name: ${multipartFile.field}");
      print("    Filename: ${multipartFile.filename}");
      print("    Length: ${multipartFile.length}");
    } else {
      print("  No image file provided to Crud.postFile.");
    }

    // add Data to request
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    print("  Request fields: ${request.fields}");

    // Send Request
    var myrequest = await request.send();
    // For get Response Body
    var response = await http.Response.fromStream(myrequest);
    print(
      "Crud.postFile: Received response. Status Code: ${response.statusCode}",
    );
    print("Crud.postFile: Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
      Map<String, dynamic> responsebody = jsonDecode(response.body);
      return Right(responsebody);
    } else {
      return const Left(StatusRequist.serverfilure);
    }
  }
}
