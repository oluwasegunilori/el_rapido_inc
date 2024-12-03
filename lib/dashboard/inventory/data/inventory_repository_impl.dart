import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/data/repository/logger_repository.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/inventory/domain/inventory_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseInventoryRepository implements InventoryRepository {
  final FirebaseFirestore firestore;
  final UserSessionManager userSessionManager;
  final LoggerRepository loggerRepository;

  FirebaseInventoryRepository(
      {required this.firestore,
      required this.userSessionManager,
      required this.loggerRepository});

  @override
  Future<void> createInventory(Inventory inventory) async {
    String uniqueId = Uuid().v4();
    String userId = await userSessionManager.getUserId();
    await firestore.collection('inventories').doc(uniqueId).set({
      'id': uniqueId,
      'name': inventory.name,
      'quantity': inventory.quantity,
      'price': inventory.price,
      'createdBy': userId,
      'description': inventory.description,
      'lastUpdated': Timestamp.now(),
      'imageUrl': inventory.imageUrl
    });
  }

  @override
  Stream<List<Inventory>> fetchInventories() {
    return firestore.collection('inventories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Inventory(
            id: doc.id,
            name: doc['name'],
            quantity: doc['quantity'],
            price: doc['price'],
            createdBy: doc['createdBy'],
            description: doc['description'],
            lastUpdated: doc['lastUpdated'] as Timestamp,
            imageUrl: doc['imageUrl']);
      }).toList();
    });
  }

  @override
  Future<void> updateInventory(Inventory inventory) async {
    final docRef = firestore.collection('inventories').doc(inventory.id);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final oldData = snapshot.data() ?? {};

      final updatedData = {
        'name': inventory.name,
        'quantity': inventory.quantity,
        'price': inventory.price,
        'description': inventory.description,
        'lastUpdated': Timestamp.now(),
        'imageUrl': inventory.imageUrl,
      };

      // Calculate changes
      final changes = loggerRepository.getChanges(
        oldData: oldData,
        newData: updatedData,
      );

      // Update the inventory
      await docRef.update(updatedData);

      // Log changes if any
      if (changes.isNotEmpty) {
        await loggerRepository.logChange(
          action: 'update',
          id: inventory.id,
          changes: changes,
        );
      }
    }
  }

  @override
  Future<void> deleteInventory(String id) async {
    await firestore.collection('inventories').doc(id).delete();
  }
}
