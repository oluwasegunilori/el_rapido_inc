import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController costPriceController =
      TextEditingController(text: inventory?.costPrice.toString());
  final TextEditingController sellingPriceController =
      TextEditingController(text: inventory?.costPrice.toString());
  final TextEditingController descriptionController =
      TextEditingController(text: inventory?.description);
  final TextEditingController imageLinkCOntroller =
      TextEditingController(text: inventory?.imageUrl);

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth =
          screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.5;
      String? copiedUrl;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title:
                Text(inventory == null ? 'Add Inventory' : "Update Inventory"),
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
                        controller: costPriceController,
                        decoration: InputDecoration(
                          labelText: 'Cost Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Cost Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: sellingPriceController,
                        decoration: InputDecoration(
                          labelText: 'Selling Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selling Price is required';
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
                      TextFormField(
                        controller: imageLinkCOntroller,
                        decoration: InputDecoration(
                          labelText: 'Image Link',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return null;
                          }
                          return !isValidUrl(value) ? 'Enter a link' : null;
                        },
                        onChanged: (value) {
                          setState(
                            () {
                              copiedUrl = value;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {},
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: !isValidUrl(copiedUrl)
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _launchURL(
                                              "https://imgur.com/upload");
                                        },
                                        child: const Text("Upload Image"),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      const Center(
                                          child: Text(
                                        'Note after uploading image,\nRight click on the image or long press and click "Copy Image address"\nThen navigate back here and paste into image link box',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      const Center(
                                          child: SelectableText(
                                              "https://imgur.com/upload"))
                                    ],
                                  )
                                : GestureDetector(
                                    child: Image.network(
                                      copiedUrl!,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      _launchURL("https://imgur.com/upload");
                                    },
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final mInventory = Inventory(
                              id: inventory?.id ?? "",
                              name: nameController.text,
                              quantity: int.parse(quantityController.text),
                              costPrice: double.parse(costPriceController.text),
                              sellingPrice:
                                  double.parse(sellingPriceController.text),
                              description: descriptionController.text,
                              imageUrl: copiedUrl,
                            );
                            onAdd(mInventory);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(inventory == null ? 'Add' : "Update"),
                      )
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
          );
        },
      );
    },
  );
}

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url),
        webOnlyWindowName: '_blank',
        mode: LaunchMode.externalApplication); // Opens in new tab
  } else {
    throw 'Could not launch $url';
  }
}

bool isValidUrl(String? url) {
  final Uri? uri = Uri.tryParse(url ?? "");
  return uri != null &&
      url != null &&
      url.contains("imgur") &&
      uri.hasScheme &&
      uri.hasAuthority;
}
