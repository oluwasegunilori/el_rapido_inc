import 'dart:typed_data';

abstract class ImageUploadRepository {
  Future<String?> uploadToImgur(Uint8List image);
}
