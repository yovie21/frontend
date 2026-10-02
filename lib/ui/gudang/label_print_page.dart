import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';

class LabelPrintPage extends StatelessWidget {
  final Product product;
  const LabelPrintPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final barcodeData = product.barcode?.isNotEmpty == true ? product.barcode! : product.sku;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cetak Label Barcode'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Pratinjau Label Rak / Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            
            // Preview Card Design
            Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${AppUtils.formatCurrency(product.price.toInt())}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F3826)),
                    ),
                    const SizedBox(height: 12),
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: barcodeData,
                      width: 220,
                      height: 70,
                      drawText: true,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'SKU: ${product.sku}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3826),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Siap terhubung ke Thermal Printer/PDF')),
                  );
                },
                icon: const Icon(Icons.print_rounded, color: Colors.white),
                label: const Text(
                  'Cetak Label Thermal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
