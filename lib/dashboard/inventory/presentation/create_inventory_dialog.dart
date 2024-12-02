import 'dart:io';
import 'dart:typed_data';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_event.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/presentation/uploader/image_upload_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

void showCreateInventoryDialog(
  BuildContext context,
  Inventory? inventory,
  Function(Inventory inventory) onAdd,
) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController =
      TextEditingController(text: inventory?.name);
  final TextEditingController quantityController =
      TextEditingController(text: inventory?.quantity.toString());
  final TextEditingController priceController =
      TextEditingController(text: inventory?.price.toString());
  final TextEditingController descriptionController =
      TextEditingController(text: inventory?.description);

  Uint8List? selectedImage;

  Future<void> pickImage() async {
    selectedImage = await ImagePickerWeb.getImageAsBytes();
  }

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth =
          screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.5;
      ImageUploadBloc imageUploadBloc = getIt<ImageUploadBloc>();

      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider(
            create: (_) => imageUploadBloc,
            child: AlertDialog(
              title: const Text('Add Inventory'),
              content: SizedBox(
                width: dialogWidth.clamp(0, 500),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity is required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Description is required'
                              : null,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        // GestureDetector(
                        //   onTap: () async {
                        //     await pickImage();
                        //     setState(() {});
                        //   },
                        //   child: Container(
                        //     height: 150,
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       border: Border.all(color: Colors.grey),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: selectedImage != null
                        //         ? Image.memory(selectedImage!, fit: BoxFit.cover)
                        //         : const Center(
                        //             child: Text('Tap to select an image')),
                        //   ),
                        // ),
                        const SizedBox(height: 16),
                        BlocConsumer<ImageUploadBloc, ImageUploadState>(
                          listener: (context, state) {
                            if (state is ImageUploadFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error)),
                              );
                            }
                          },
                          builder: (context, state) {
                            // if (state is ImageUploading) {
                            //   return const CircularProgressIndicator();
                            // } else if (state is ImageUploadSuccess) {
                            return ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final mInventory = Inventory(
                                    id: inventory?.id ?? "",
                                    name: nameController.text,
                                    quantity:
                                        int.parse(quantityController.text),
                                    price: double.parse(priceController.text),
                                    description: descriptionController.text,
                                    imageUrl: "https://i.imgur.com/9lZIAUW.png",
                                  );
                                  onAdd(mInventory);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(inventory == null ? 'Add' : "Update"),
                            );
                            // } else {
                            //   return ElevatedButton(
                            //     onPressed: () {
                            //       if (selectedImage != null) {
                            //         imageUploadBloc
                            //             .add(UploadImage(selectedImage!));
                            //       } else {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           const SnackBar(
                            //               content: Text('No image selected')),
                            //         );
                            //       }
                            //     },
                            //     child: const Text('Upload Image'),
                            //   );
                            // }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
