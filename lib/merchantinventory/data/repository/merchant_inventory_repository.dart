import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:el_rapido_inc/merchantinventory/data/model/merchant_inventory.dart';

abstract class MerchantInventoryRepository {
  Future<void> createMerchantInventory(MerchantInventory inventory);
  Future<void> updateMerchantInventoryQuantity(String id, int quantity);
  Future<void> updateMerchantInventoryPrice(String id, double price);
  Stream<List<MerchantInventory>>
      fetchMerchantInventoriesByMerchantAndInventoryIds(
          String merchantId, String inventoryId);
  Stream<List<MerchantInventory>> fetchMerchantInventoriesByMerchantId(
      String merchantId);
  Future<void> reduceQuantity(String id, int quantity);
}

class MerchantInventoryRepositoryImpl implements MerchantInventoryRepository {
  final FirebaseFirestore _firestore;
  final InventoryRepository inventoryRepository;

  MerchantInventoryRepositoryImpl(this._firestore, this.inventoryRepository);

  @override
  Future<void> createMerchantInventory(MerchantInventory inventory) async {
    final map = inventory.toCreateMap();
    await _firestore.collection('merchant_inventories').doc(map["id"]).set(map);
    await _firestore
        .collection("inventories")
        .doc(inventory.inventoryId)
        .update({"quantity": FieldValue.increment(-inventory.quantity)});
  }

  @override
  Future<void> updateMerchantInventoryQuantity(String id, int quantity) async {
    await _firestore
        .collection('merchant_inventories')
        .doc(id)
        .update({'quantity': quantity});
  }

  @override
  Future<void> updateMerchantInventoryPrice(String id, double price) async {
    await _firestore
        .collection('merchant_inventories')
        .doc(id)
        .update({'price': price});
  }

  @override
  Stream<List<MerchantInventory>>
      fetchMerchantInventoriesByMerchantAndInventoryIds(
          String merchantId, String inventoryId) {
    return _firestore
        .collection('merchant_inventories')
        .where('merchantId', isEqualTo: merchantId)
        .where('inventoryId', isEqualTo: inventoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MerchantInventory.fromMap(doc.data()))
            .toList());
  }

  @override
  Stream<List<MerchantInventory>> fetchMerchantInventoriesByMerchantId(
      String merchantId) {
    return _firestore
        .collection('merchant_inventories')
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MerchantInventory.fromMap(doc.data()))
            .toList());
  }

  @override
  Future<void> reduceQuantity(String id, int quantity) async {
    _firestore
        .collection('merchant_inventories')
        .doc(id)
        .update({"quantity": FieldValue.increment(-quantity)});
  }
}
