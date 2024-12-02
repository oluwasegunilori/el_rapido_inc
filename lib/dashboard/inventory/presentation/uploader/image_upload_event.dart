import 'dart:typed_data';

abstract class ImageUploadEvent {}

class UploadImage extends ImageUploadEvent {
  final Uint8List image;

  UploadImage(this.image);
}
