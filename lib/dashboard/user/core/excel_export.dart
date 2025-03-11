import 'dart:typed_data';

import 'package:el_rapido_inc/dashboard/inventory/domain/inventory.dart';
import 'package:el_rapido_inc/dashboard/merchant/data/model/mechants_model.dart';
import 'package:el_rapido_inc/dashboard/transaction/data/model/transaction_model.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

Future<void> exportToExcel(List<Transaction> transactions,
    List<Inventory> inventories, List<Merchant>? merchants) async {
  final excel = Excel.createExcel();
  final sheet = excel['Transactions'];

  // Define header row and make it bold
  var headerStyle = CellStyle(
    bold: true,
  );

  // Add headers
  sheet.appendRow([
    TextCellValue('Merchant'),
    TextCellValue('Inventory'),
    TextCellValue('Quantity'),
    TextCellValue('Price'),
    TextCellValue('Total Price'),
    TextCellValue('Date'),
  ]);

  // Add header row
  for (int i = 0; i < sheet.maxColumns; i++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        .cellStyle = headerStyle; // Apply bold style
  }
  // Add data rows and calculate total amount
  double totalAmount = 0.0;
  for (var transaction in transactions) {
    String merchantName =
        merchants!.firstWhere((e) => e.id == transaction.merchantId).name;
    String inventoryName =
        inventories.firstWhere((e) => e.id == transaction.inventoryId).name;

    double transactionTotalPrice = transaction.totalPrice;

    sheet.appendRow([
      TextCellValue(merchantName),
      TextCellValue(inventoryName),
      TextCellValue(transaction.quantity.toString()),
      TextCellValue(transaction.price.toStringAsFixed(2)),
      TextCellValue(transactionTotalPrice.toStringAsFixed(2)),
      TextCellValue(_formatDate(transaction.date)),
    ]);

    // Add to total amount
    totalAmount += transactionTotalPrice;
  }

  // Add total amount row at the bottom of the Total Price column
  sheet.appendRow([
    TextCellValue('Total Amount'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(totalAmount.toStringAsFixed(2)),
    TextCellValue('')
  ]);

  sheet
      .cell(CellIndex.indexByColumnRow(
          columnIndex: 4, rowIndex: transactions.length + 1))
      .cellStyle = headerStyle;

  // Convert the Excel file to bytes
  final bytes = excel.encode()!;

  // Trigger the download process (web)
  final buffer = Uint8List.fromList(bytes);
  final blob = html.Blob([buffer]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = 'transactions.xlsx'
    ..click();

  // Clean up by revoking the object URL
  html.Url.revokeObjectUrl(url);
}

String _formatDate(DateTime date) {
  return DateFormat("dd MMM yyyy, hh:mm a").format(date);
}
