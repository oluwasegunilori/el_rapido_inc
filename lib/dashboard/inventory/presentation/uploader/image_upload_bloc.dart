import 'package:el_rapido_inc/dashboard/inventory/domain/image_upload_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_event.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  final ImageUploadRepository _imageRepository;

  ImageUploadBloc(this._imageRepository) : super(ImageUploadInitial()) {
    on<UploadImage>((event, emit) async {
      emit(ImageUploading());
      try {
        final imageUrl = await _imageRepository.uploadToImgur(event.image);
        if (imageUrl != null) {
          emit(ImageUploadSuccess(imageUrl));
        } else {
          emit(ImageUploadFailure('Failed to upload image'));
        }
      } catch (e) {
        emit(ImageUploadFailure(e.toString()));
      }
    });
  }
}
