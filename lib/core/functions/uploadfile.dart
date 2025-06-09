import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

imageUploadCamera() async {
  final XFile? file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 50,
  );
  if (file != null) {
    return File(file.path);
  } else {
    return null;
  }
}

fileUploadGallery([isSvg = false]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions:
        isSvg
            ? ["svg", "SVG"]
            : [
              'jpg',
              "JPG",
              'jpeg',
              "JPEG",
              'png',
              "PNG",
              "WEBP",
              "webp",
              "GIF",
              "gif",
              "BMP",
              "bmp",
              "TIFF",
              "tiff",
              "HEIC",
              "heic",
            ],
  );

  if (result != null) {
    return File(result.files.first.path!);
  } else {
    return null;
  }
}
