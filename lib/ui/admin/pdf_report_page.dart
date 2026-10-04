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
  
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Future<void> _generatePdf() async {
    setState(() => loading = true);
    try {
      final doc = pw.Document();
      final printDate = DateTime.now().toIso8601String().substring(0, 16).replaceAll('T', ' ');
      final fromStr = fromDate.toIso8601String().substring(0, 10);
      final toStr = toDate.toIso8601String().substring(0, 10);
      final brandColor = PdfColor.fromHex('#0F3826');

      if (kind == 'sales') {
        final res = await SaleService.getSales(from: fromStr, to: toStr);
        final totalNet = res.fold<double>(0, (sum, s) => sum + (double.tryParse(s.total.toString()) ?? 0.0));

        doc.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) => [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('WARUNGKU', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: brandColor)),
                      pw.SizedBox(height: 2),
                      pw.Text('Sistem Kasir & Manajemen Toko Kelontong', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('LAPORAN PENJUALAN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandColor)),
                      pw.SizedBox(height: 2),
                      pw.Text('Periode: $fromStr s/d $toStr', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      pw.Text('Dicetak: $printDate', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 20, color: brandColor, thickness: 1.5),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Total Transaksi: ${res.length} Nota', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Total Omzet: Rp ${AppUtils.formatCurrency(totalNet)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: brandColor)),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.TableHelper.fromTextArray(
                headers: ['No', 'No. Nota', 'Waktu', 'Kasir', 'Metode', 'Total Bayar'],
                data: res.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final s = entry.value;
                  return [
                    i.toString(),
                    s.invoiceNo,
                    s.saleDate?.substring(0, 16).replaceAll('T', ' ') ?? '-',
                    'Kasir',
                    s.paymentMethod.toUpperCase(),
                    'Rp ${AppUtils.formatCurrency(s.total)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: pw.BoxDecoration(color: brandColor),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FlexColumnWidth(2)},
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    width: 140,
                    child: pw.Column(children: [
                      pw.Text('Dibuat Oleh,', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Container(height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Kasir / Admin', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    width: 140,
                    child: pw.Column(children: [
                      pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Container(height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Pemilik Toko', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        final res = await HttpClient.get('/reports/debt?from=$fromStr&to=$toStr') as Map<String, dynamic>;
        final items = (res['items'] as List?) ?? [];
        final totalHutang = res['totalHutang'] ?? 0;

        doc.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) => [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('WARUNGKU', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: brandColor)),
                      pw.SizedBox(height: 2),
                      pw.Text('Sistem Kasir & Manajemen Toko Kelontong', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('LAPORAN HUTANG SUPPLIER', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandColor)),
                      pw.SizedBox(height: 2),
                      pw.Text('Periode: $fromStr s/d $toStr', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      pw.Text('Dicetak: $printDate', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 20, color: brandColor, thickness: 1.5),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Total Supplier PO: ${items.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Total Sisa Hutang: Rp ${AppUtils.formatCurrency(totalHutang)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.red700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.TableHelper.fromTextArray(
                headers: ['No', 'No. PO', 'Supplier', 'Tagihan', 'Terbayar', 'Sisa Hutang'],
                data: items.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final p = entry.value as Map<String, dynamic>;
                  return [
                    i.toString(),
                    p['poNo'] ?? '-',
                    p['supplierName'] ?? '-',
                    'Rp ${AppUtils.formatCurrency(p['total'])}',
                    'Rp ${AppUtils.formatCurrency(p['paid'])}',
                    'Rp ${AppUtils.formatCurrency(p['unpaid'])}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: pw.BoxDecoration(color: brandColor),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {0: const pw.FixedColumnWidth(30)},
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    width: 140,
                    child: pw.Column(children: [
                      pw.Text('Dibuat Oleh,', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Container(height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Admin Gudang', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    width: 140,
                    child: pw.Column(children: [
                      pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Container(height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Pemilik Toko', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ),
                ],
              ),
            ],
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text('Dari: ${fromDate.toIso8601String().substring(0, 10)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text('Sampai: ${toDate.toIso8601String().substring(0, 10)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : _generatePdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(loading ? 'Memproses...' : 'Pratinjau & Cetak PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
