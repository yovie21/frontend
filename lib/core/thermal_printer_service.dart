import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/models.dart';
import 'utils.dart';

class ThermalPrinterService {
  /// Mencetak struk kasir dengan format roll thermal 58mm
  static Future<void> printReceipt({
    required Sale sale,
    List<dynamic>? items,
    String storeName = 'WARUNGKU',
    String storeAddress = 'Solusi Belanja Kebutuhan Harian',
  }) async {
    try {
      final doc = pw.Document();

      final saleItems = items ?? sale.items;
      final saleDateStr = sale.saleDate != null
          ? DateTime.tryParse(sale.saleDate!)?.toLocal().toString().substring(0, 16) ?? sale.saleDate!
          : DateTime.now().toString().substring(0, 16);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    storeName,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    storeAddress,
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),

                // Meta Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('No: ${sale.nota}', style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Text(saleDateStr, style: const pw.TextStyle(fontSize: 7.5)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kasir: Kasir Warungku', style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Text(sale.paymentMethod.toUpperCase(), style: const pw.TextStyle(fontSize: 7.5)),
                  ],
                ),
                pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),

                // Items list
                ...saleItems.map((raw) {
                  final it = raw as Map<String, dynamic>;
                  final name = it['product']?['name'] ?? it['productName'] ?? 'Item';
                  final qty = it['qty'] ?? 1;
                  final price = double.tryParse((it['unitPrice'] ?? it['price'] ?? 0).toString()) ?? 0.0;
                  final subtotal = qty * price;

                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '$name',
                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                          maxLines: 1,
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '  $qty x ${AppUtils.formatCurrency(price)}',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                            pw.Text(
                              'Rp ${AppUtils.formatCurrency(subtotal)}',
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),

                // Totals
                if (sale.discount > 0)
                  _thermalRow('Diskon Promo', '-Rp ${AppUtils.formatCurrency(sale.discount)}'),
                _thermalRow('TOTAL', 'Rp ${AppUtils.formatCurrency(sale.total)}', bold: true, fontSize: 9),

                if (sale.paymentMethod == 'tunai') ...[
                  _thermalRow('Tunai Diterima', 'Rp ${AppUtils.formatCurrency(sale.cashPaid)}'),
                  _thermalRow('Kembalian', 'Rp ${AppUtils.formatCurrency(sale.changeGiven)}', bold: true),
                ],

                pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 4),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Terima Kasih Telah Berbelanja!',
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Barang yang dibeli tidak dapat ditukar.',
                    style: const pw.TextStyle(fontSize: 6.5),
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
            );
          },
        ),
      );

      // Buka dialog printer thermal langsung (mendeteksi printer thermal Bluetooth/USB/WiFi)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Struk_${sale.nota}',
      );
    } catch (e) {
      debugPrint('Error direct thermal print: $e');
      rethrow;
    }
  }

  static pw.Widget _thermalRow(String label, String value, {bool bold = false, double fontSize = 7.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
