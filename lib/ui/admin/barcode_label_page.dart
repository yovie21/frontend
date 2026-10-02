import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/models/models.dart';
import '../../providers/admin_provider.dart';

class BarcodeLabelPage extends StatefulWidget {
  const BarcodeLabelPage({super.key});

  @override
  State<BarcodeLabelPage> createState() => _BarcodeLabelPageState();
}

class _BarcodeLabelPageState extends State<BarcodeLabelPage> {
  Product? _selectedProduct;
  int _copies = 1;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      if (admin.products.isEmpty) {
        admin.fetchProducts();
      }
    });
  }

  Future<void> _printLabel(Product product, int count) async {
    final doc = pw.Document();

    final codeToUse = (product.barcode != null && product.barcode!.isNotEmpty)
        ? product.barcode!
        : product.sku;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              for (int i = 0; i < count; i++) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        product.name,
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Rp ${AppUtils.formatCurrency(product.price.toInt())}',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 8),
                      pw.BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: codeToUse,
                        width: 180,
                        height: 50,
                        drawText: true,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('SKU: ${product.sku}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'label_${product.sku}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = admin.products.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          (p.barcode?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cetak Label & Barcode Rak',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari nama produk, SKU, atau barcode...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F3826)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: _selectedProduct == null
                ? (filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final p = filtered[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              subtitle: Text(
                                'SKU: ${p.sku} · Barcode: ${p.barcode ?? '-'} · Rp ${AppUtils.formatCurrency(p.price.toInt())}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              trailing: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F3826),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: Colors.white),
                                label: const Text('Pilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                onPressed: () {
                                  setState(() {
                                    _selectedProduct = p;
                                    _copies = 1;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Card Preview Label Rak
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0x080F172A), blurRadius: 16, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PREVIEW LABEL RAK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF065F46),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _selectedProduct!.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${AppUtils.formatCurrency(_selectedProduct!.price.toInt())}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F3826),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: BarcodeWidget(
                                  barcode: Barcode.code128(),
                                  data: (_selectedProduct!.barcode != null && _selectedProduct!.barcode!.isNotEmpty)
                                      ? _selectedProduct!.barcode!
                                      : _selectedProduct!.sku,
                                  width: 220,
                                  height: 70,
                                  drawText: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'SKU: ${_selectedProduct!.sku}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Jumlah Salinan / Copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Jumlah Cetak:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _copies > 1 ? () => setState(() => _copies--) : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text('$_copies', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _copies++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tombol Aksi
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () => setState(() => _selectedProduct = null),
                                child: const Text('Ganti Produk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F3826),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.print_rounded, color: Colors.white),
                                label: const Text(
                                  'Cetak PDF Label',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                                ),
                                onPressed: () => _printLabel(_selectedProduct!, _copies),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
