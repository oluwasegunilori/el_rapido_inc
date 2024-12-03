import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LoggerRepository {
  /// Logs changes made to an inventory item.
  ///
  /// [action] specifies the type of action, e.g., 'create', 'update', or 'delete'.
  /// [id] is the ID of the inventory item.
  /// [changes] contains a map of the fields that were changed, including old and new values.
  Future<void> logChange({
    required String action,
    required String id,
    required Map<String, dynamic> changes,
  });

  /// Computes changes between the old and new inventory states.
  Map<String, Map<String, dynamic>> getChanges({
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  });
}

class FirebaseLoggerRepository implements LoggerRepository {
  final FirebaseFirestore firestore;

  FirebaseLoggerRepository(this.firestore);

  @override
  Future<void> logChange({
    required String action,
    required String id,
    required Map<String, dynamic> changes,
  }) async {
    try {
      final logRef = firestore.collection('InventoryLogs').doc();

      final log = {
        'action': action,
        'inventoryId': id,
        'changes': changes,
        'timestamp': Timestamp.now(),
      };

      await logRef.set(log);
    } catch (e) {
      // Optionally handle or rethrow exceptions for further processing
      throw Exception('Failed to log inventory change: $e');
    }
  }

  @override
  Map<String, Map<String, dynamic>> getChanges({
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) {
    final changes = <String, Map<String, dynamic>>{};

    oldData.forEach((key, oldValue) {
      final newValue = newData[key];
      if (oldValue != newValue && newValue != null) {
        changes[key] = {'old': oldValue, 'new': newValue};
      }
    });

    // Check for keys that only exist in newData
    newData.forEach((key, newValue) {
      if (!oldData.containsKey(key)) {
        changes[key] = {'old': null, 'new': newValue};
      }
    });

    return changes;
  }
}
