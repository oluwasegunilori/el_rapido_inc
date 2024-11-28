import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseInventoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> createInventory(Inventory inventory) async {
    String uniqueId = Uuid().v4();
    await _firestore.collection('inventories').doc(uniqueId).set({
      'id': uniqueId,
      'name': inventory.name,
      'quantity': inventory.quantity,
      'price': inventory.price,
      'createdBy': inventory.createdBy,
      'description': inventory.description,
      'lastUpdated': Timestamp.now()
    });
  }

  @override
  Stream<List<Inventory>> fetchInventories() {
    return _firestore.collection('inventories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Inventory(
          id: doc.id,
          name: doc['name'],
          quantity: doc['quantity'],
          price: doc['price'],
          createdBy: doc['createdBy'],
          description: doc['description'],
          lastUpdated: doc['lastUpdated'] as Timestamp,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateInventory(Inventory inventory) async {
    await _firestore.collection('inventories').doc(inventory.id).update({
      'name': inventory.name,
      'quantity': inventory.quantity,
      'price': inventory.price,
      'createdBy': inventory.createdBy,
      'description': inventory.description,
      'lastUpdated': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteInventory(String id) async {
    await _firestore.collection('inventories').doc(id).delete();
  }
}
