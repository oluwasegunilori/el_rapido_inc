import 'package:cloud_firestore/cloud_firestore.dart' as _firestore;
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(Transaction transaction);
  Stream<List<Transaction>> fetchTransactions({
    String? merchantId,
    String? inventoryId,
    DateTimeRange? dateRange,
    String? createdBy,
  });
}

class TransactionRepositoryImpl implements TransactionRepository {
  final _firestore.FirebaseFirestore firestore;
  final UserSessionManager userSessionManager;

  TransactionRepositoryImpl(this.firestore, this.userSessionManager);

  @override
  Future<void> createTransaction(Transaction transaction) async {
    String uniqueId = const Uuid().v4();
    String userId = await userSessionManager.getUserId();

    Transaction readyTransaction =
        transaction.copyWith(id: uniqueId, createdBy: userId);

    await firestore
        .collection('transactions')
        .doc(readyTransaction.id)
        .set(readyTransaction.toMap());
  }

  @override
  Stream<List<Transaction>> fetchTransactions({
    String? merchantId,
    String? inventoryId,
    DateTimeRange? dateRange,
    String? createdBy,
  }) {
    _firestore.Query query = firestore.collection('transactions');

    if (merchantId != null) {
      query = query.where('merchantId', isEqualTo: merchantId);
    }
    if (inventoryId != null) {
      query = query.where('inventoryId', isEqualTo: inventoryId);
    }
    if (dateRange != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: dateRange.start.toIso8601String(),
      );
      query = query.where(
        'date',
        isLessThanOrEqualTo: dateRange.end.toIso8601String(),
      );
    }
    if (createdBy != null) {
      query = query.where('createdBy', isEqualTo: createdBy);
    }
    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Transaction.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
