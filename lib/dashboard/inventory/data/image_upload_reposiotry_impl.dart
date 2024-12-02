import 'package:dio/dio.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/image_upload_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ImageUploadRepostoryImpl extends ImageUploadRepository {
  final Dio dio;

  ImageUploadRepostoryImpl({required this.dio});

  @override
  Future<String?> uploadToImgur(Uint8List image) async {
    const clientId = 'KNOWNOT'; // Replace with your Imgur Client ID
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(image, filename: Uuid().v4()),
      });
      final response = await dio.post(
        'https://api.imgur.com/3/image',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Client-ID $clientId'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data']['link']; // Return the Imgur image URL
      }
    } catch (e) {
      print(e);
      throw Exception('Image upload failed: $e');
    }
    return null;
  }
}
