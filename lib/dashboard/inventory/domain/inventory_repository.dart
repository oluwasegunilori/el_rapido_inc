import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';

abstract class InventoryRepository {
  Future<void> createInventory(Inventory inventory);
  Stream<List<Inventory>> fetchInventories(); // Changed to Stream
  Future<void> updateInventory(Inventory inventory);
  Future<void> deleteInventory(String id);
}
