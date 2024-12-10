import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/merchant_inventory.dart';
import 'package:uuid/uuid.dart';

abstract class MerchantsRepository {
  Future<void> createMerchant(Merchant merchant);
  Stream<List<Merchant>> fetchMerchants();
  Future<void> updateMerchant(Merchant merchant);
  Future<void> deleteMerchant(String id);
  Future<void> updateInventoryList(String merchantId,
      List<MerchantInventory> inventoryList, int inventoryPosition);
  Future<List<Inventory>> fetchFullInventory(List<String> inventoryIds);
  Future<List<Merchant>> fetchMerchantsByInventoryId(String inventoryId);
}

class MerchantsRepositoryImpl implements MerchantsRepository {
  final FirebaseFirestore _firestore;
  final InventoryRepository inventoryRepository;

  MerchantsRepositoryImpl(this._firestore, this.inventoryRepository);

  @override
  Future<void> createMerchant(Merchant merchant) async {
    final id = const Uuid().v4();
    final merchantDoc = _firestore.collection('merchants').doc(id);
    await merchantDoc.set({
      'id': id,
      'name': merchant.name,
      'location': merchant.location,
      'inventoryList': [],
    });
  }

  @override
  Stream<List<Merchant>> fetchMerchants() {
    return _firestore
        .collection('merchants')
        .snapshots() // This provides a stream of snapshots
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Merchant(
          id: data['id'],
          name: data['name'],
          location: data['location'],
          inventoryList: (data['inventoryList'] as List)
              .map((item) => MerchantInventory.fromMap(item))
              .toList(),
        );
      }).toList();
    });
  }

  @override
  Future<void> updateMerchant(Merchant merchant) async {
    final merchantDoc = _firestore.collection('merchants').doc(merchant.id);
    await merchantDoc.update({
      'name': merchant.name,
      'location': merchant.location,
      'inventoryList':
          merchant.inventoryList.map((inv) => inv.toMap()).toList(),
    });
  }

  @override
  Future<void> deleteMerchant(String id) async {
    await _firestore.collection('merchants').doc(id).delete();
  }

  @override
  Future<void> updateInventoryList(String merchantId,
      List<MerchantInventory> inventoryList, int inventoryPosition) async {
    final merchantDoc = _firestore.collection('merchants').doc(merchantId);
    await merchantDoc.update({
      'inventoryList': inventoryList.map((inv) => inv.toMap()).toList(),
    });
    final inventory = inventoryList[inventoryPosition];

    await inventoryRepository.updateInventoryQuantity(
        inventory.inventoryId, inventory.quantity);
  }

  @override
  Future<List<Inventory>> fetchFullInventory(List<String> inventoryIds) async {
    final inventoryDocs = await _firestore
        .collection('inventory')
        .where(FieldPath.documentId, whereIn: inventoryIds)
        .get();

    return inventoryDocs.docs.map((doc) {
      final data = doc.data();
      return Inventory.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<List<Merchant>> fetchMerchantsByInventoryId(String inventoryId) async {
    final querySnapshot = await _firestore.collection('merchants').where(
        'inventoryList',
        arrayContains: {'inventoryId': inventoryId}).get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Merchant(
        id: data['id'],
        name: data['name'],
        location: data['location'],
        inventoryList: (data['inventoryList'] as List)
            .map((item) => MerchantInventory.fromMap(item))
            .toList(),
      );
    }).toList();
  }
}
