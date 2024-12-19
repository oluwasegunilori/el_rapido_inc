import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:flutter/material.dart';

abstract class TransactionEvent {}

class CreateTransaction extends TransactionEvent {
  final Transaction transaction;

  CreateTransaction(this.transaction);
}

class FetchTransactions extends TransactionEvent {
  final String? merchantId;
  final String? inventoryId;
  final DateTimeRange? dateRange;
  final String? createdBy;

  FetchTransactions(
      {this.merchantId, this.inventoryId, this.dateRange, this.createdBy});
}
