abstract class ImageUploadState {}

class ImageUploadInitial extends ImageUploadState {}

class ImageUploading extends ImageUploadState {}

class ImageUploadSuccess extends ImageUploadState {
  final String imageUrl;

  ImageUploadSuccess(this.imageUrl);
}

class ImageUploadFailure extends ImageUploadState {
  final String error;

  ImageUploadFailure(this.error);
}
