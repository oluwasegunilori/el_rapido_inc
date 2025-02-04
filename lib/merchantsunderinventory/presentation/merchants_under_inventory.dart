import 'package:flutter/material.dart';

class MerchantsUnderInventory extends StatelessWidget {
  final String inventoryId;

  const MerchantsUnderInventory({super.key, required this.inventoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Adjust height as needed
        child: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Merchants", style: TextStyle(fontSize: 18)),
            ],
          ),
          elevation: 4,
        ),
      ),
      body: Center(child: Text(inventoryId)),
    );
  }
}
