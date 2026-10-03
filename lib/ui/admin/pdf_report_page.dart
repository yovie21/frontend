import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/http_client.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/services/services.dart';

class PdfReportPage extends StatefulWidget {
  const PdfReportPage({super.key});

  @override
  State<PdfReportPage> createState() => _PdfReportPageState();
}

class _PdfReportPageState extends State<PdfReportPage> {
  String kind = 'sales';
  bool loading = false;

  Future<void> _generatePdf() async {
    setState(() => loading = true);
    try {
      final doc = pw.Document();
      if (kind == 'sales') {
        final res = await SaleService.getSales();
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LAPORAN PENJUALAN', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Dicetak: ${DateTime.now().toIso8601String().substring(0, 16)}'),
                pw.Divider(),
                pw.TableHelper.fromTextArray(
                  headers: ['Nota', 'Total', 'Metode'],
                  data: res.take(50).map((s) => [s.invoiceNo, 'Rp ${AppUtils.formatCurrency(s.total)}', s.paymentMethod]).toList(),
                ),
              ],
            ),
          ),
        );
      } else {
        final res = await HttpClient.get('/reports/debt') as Map<String, dynamic>;
        final items = (res['items'] as List?) ?? [];
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LAPORAN HUTANG SUPPLIER', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Total Hutang: Rp ${AppUtils.formatCurrency(res['totalHutang'])}'),
                pw.Divider(),
                pw.TableHelper.fromTextArray(
                  headers: ['Supplier', 'Total', 'Terbayar', 'Sisa'],
                  data: items.take(50).map((raw) {
                    final p = raw as Map<String, dynamic>;
                    return [
                      p['supplierName'] ?? '-',
                      'Rp ${AppUtils.formatCurrency(p['total'])}',
                      'Rp ${AppUtils.formatCurrency(p['paid'])}',
                      'Rp ${AppUtils.formatCurrency(p['unpaid'])}',
                    ];
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Export Laporan PDF', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'sales', label: Text('Penjualan')),
                ButtonSegment(value: 'debt', label: Text('Hutang')),
              ],
              selected: {kind},
              onSelectionChanged: (s) => setState(() => kind = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: loading ? null : _generatePdf,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(loading ? 'Memproses...' : 'Pratinjau & Cetak PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
