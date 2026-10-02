import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/kasir_provider.dart';
import '../widgets/camera_scanner_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _searchCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  List<Category> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KasirProvider>().fetchProducts();
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (e) {
      debugPrint('Category load error: $e');
    }
  }

  Future<void> _openCameraScanner() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const CameraScannerPage(title: 'Scan Barcode Kasir'),
      ),
    );
    if (code != null && code.isNotEmpty && mounted) {
      _barcodeCtrl.text = code;
      _scanBarcode(code);
    }
  }

  void _scanBarcode(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;

    final kasir = context.read<KasirProvider>();
    final p = kasir.products
        .where((e) => (e.barcode ?? '').trim() == cleanCode || e.sku.trim() == cleanCode)
        .firstOrNull;
    if (p != null) {
      if (p.productUoms != null && p.productUoms!.isNotEmpty) {
        _showUomSelectorModal(p);
      } else {
        kasir.addToCart(p);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F3826),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('${p.name} ditambahkan ke keranjang')),
              ],
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      _barcodeCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Produk dengan barcode/SKU "$cleanCode" tidak ditemukan'),
        ),
      );
    }
  }

  void _showUomSelectorModal(Product p) {
    final kasir = context.read<KasirProvider>();
    final baseSymbol = (p.uom?['symbol'] ?? 'PCS').toString();
    final List<Map<String, dynamic>> uomOptions = [
      {
        'symbol': baseSymbol,
        'name': p.uom?['name'] ?? 'Satuan Utama',
        'price': p.price,
        'factor': 1,
      }
    ];

    if (p.productUoms != null) {
      for (final pu in p.productUoms!) {
        final symbol = (pu['uom']?['symbol'] ?? pu['uom']?['name'] ?? 'UOM').toString();
        final price = (pu['price'] as num).toDouble();
        final factor = (pu['conversionFactor'] as num).toInt();
        uomOptions.add({
          'symbol': symbol,
          'name': 'Isi $factor $baseSymbol',
          'price': price,
          'factor': factor,
        });
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Satuan — ${p.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Stok tersedia: ${p.stock} ${p.uom?['symbol'] ?? 'PCS'}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            for (final opt in uomOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    kasir.addToCart(
                      p,
                      customPrice: opt['price'],
                      uomSymbol: opt['symbol'],
                      conversionFactor: opt['factor'],
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${opt['symbol'].toString().toUpperCase()} (${opt['name']})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (opt['factor'] > 1)
                              Text(
                                'Konversi: 1 ${opt['symbol']} = ${opt['factor']} ${p.uom?['symbol'] ?? 'PCS'}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                        Text(
                          'Rp ${AppUtils.formatCurrency(opt['price'])}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showCustomUomModal(p);
              },
              icon: const Icon(Icons.add),
              label: const Text('Satuan lain'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomUomModal(Product p) {
    final kasir = context.read<KasirProvider>();
    final symbolCtrl = TextEditingController();
    final factorCtrl = TextEditingController(text: '12');
    final priceCtrl = TextEditingController();
    final base = (p.uom?['symbol'] ?? 'PCS').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Satuan lain — ${p.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                controller: symbolCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Nama satuan (DUS, KARTON, PACK)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: factorCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: '1 satuan = berapa $base'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                decoration: const InputDecoration(labelText: 'Harga jual satuan ini', prefixText: 'Rp '),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final factor = int.tryParse(factorCtrl.text) ?? 0;
                  final price = AppUtils.parseCurrency(priceCtrl.text);
                  final symbol = symbolCtrl.text.trim();
                  if (symbol.isEmpty || factor < 1 || price <= 0) return;
                  Navigator.pop(ctx);
                  kasir.addToCart(p, customPrice: price, uomSymbol: symbol, conversionFactor: factor);
                },
                child: const Text('Masuk keranjang'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(
    Sale s,
    List<Map<String, dynamic>> items,
    double cashPaid,
    double changeGiven,
    String paymentMethod,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Badge
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 36),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Nota: ${s.nota}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Paper Receipt Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Items List (Max 5 items, scrollable if more)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (ctx, i) {
                          final it = items[i];
                          final qty = it['qty'] as int? ?? 1;
                          final price = (it['price'] as num?)?.toDouble() ?? 0.0;
                          final uom = it['uomSymbol'] ?? 'pcs';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${it['name']} x$qty $uom',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Rp ${AppUtils.formatCurrency(price * qty)}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const Divider(height: 18, color: Color(0xFFCBD5E1)),

                    // Totals
                    _receiptRow('Total Belanja', s.total, bold: true, fontSize: 14),
                    const SizedBox(height: 4),
                    _receiptRow('Metode Bayar', 0, customVal: paymentMethod.toUpperCase()),
                    if (paymentMethod == 'tunai') ...[
                      const SizedBox(height: 4),
                      _receiptRow('Uang Diterima', cashPaid),
                      const Divider(height: 16, color: Color(0xFFCBD5E1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'KEMBALIAN',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                          ),
                          Text(
                            'Rp ${AppUtils.formatCurrency(changeGiven)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: Print & Selesai
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFF0F3826), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.print_rounded, size: 18, color: Color(0xFF0F3826)),
                      label: const Text(
                        'Cetak Nota',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F3826)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF0F3826),
                            content: Row(
                              children: [
                                const Icon(Icons.print_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text('Mencetak nota ${s.nota}...')),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3826),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(dlgCtx),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, double value, {bool bold = false, double fontSize = 12, String? customVal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          customVal ?? 'Rp ${AppUtils.formatCurrency(value)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            color: bold ? const Color(0xFF0F3826) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  void _showCheckoutModal(KasirProvider kasir) {
    final cashCtrl = TextEditingController();
    final discCtrl = TextEditingController(text: '0');
    var method = 'tunai';
    var isProcessing = false;
    const methods = [
      ('tunai', 'Tunai'),
      ('qris', 'QRIS'),
      ('transfer', 'Transfer'),
      ('debit', 'Debit'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          final disc = AppUtils.parseCurrency(discCtrl.text);
          final total = (kasir.subtotal - disc).clamp(0.0, double.infinity);
          final cash = method == 'tunai' ? AppUtils.parseCurrency(cashCtrl.text) : total;
          final sisa = cash - total;
          final canPay = total > 0 && (method != 'tunai' || cash >= total);

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final m in methods)
                        ChoiceChip(
                          label: Text(m.$2),
                          selected: method == m.$1,
                          onSelected: (_) => setM(() => method = m.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _summaryRow('Subtotal', kasir.subtotal),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                    decoration: const InputDecoration(labelText: 'Diskon (Rp)', prefixText: 'Rp '),
                    onChanged: (_) => setM(() {}),
                  ),
                  const Divider(height: 24),
                  _summaryRow('Total', total, bold: true, fontSize: 18),
                  if (method == 'tunai') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: cashCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                      decoration: const InputDecoration(labelText: 'Uang tunai *', prefixText: 'Rp '),
                      onChanged: (_) => setM(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kembalian: Rp ${sisa >= 0 ? AppUtils.formatCurrency(sisa) : 0}',
                      style: TextStyle(fontWeight: FontWeight.w800, color: sisa >= 0 ? AppColors.successFg : AppColors.alertFg),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3826),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (!canPay || isProcessing)
                          ? null
                          : () async {
                              setM(() => isProcessing = true);
                              // Copy cart items snapshot before checkout clears cart
                              final purchasedItems = List<Map<String, dynamic>>.from(
                                kasir.cart.map((e) => Map<String, dynamic>.from(e)),
                              );

                              final s = await kasir.checkout(cash, discount: disc, paymentMethod: method);
                              if (!ctx.mounted) return;
                              setM(() => isProcessing = false);

                              if (s != null) {
                                Navigator.pop(ctx);
                                if (!mounted) return;
                                _showReceiptDialog(s, purchasedItems, cash, sisa, method);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFFDC2626),
                                    content: Text(kasir.errorMessage ?? 'Gagal memproses transaksi'),
                                  ),
                                );
                              }
                            },
                      child: isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Memproses Transaksi...',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                ),
                              ],
                            )
                          : Text(
                              method == 'tunai'
                                  ? 'BAYAR  ·  Rp ${AppUtils.formatCurrency(total)}'
                                  : 'PROSES ${method.toUpperCase()}  ·  Rp ${AppUtils.formatCurrency(total)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: fontSize)),
        Text('Rp ${AppUtils.formatCurrency(value)}', style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w700, fontSize: fontSize, color: bold ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasir = context.watch<KasirProvider>();
    final filteredProducts = _selectedCategoryId == null
        ? kasir.products
        : kasir.products.where((p) => p.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Kasir POS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(
                '${filteredProducts.length} Produk',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Search & Barcode Scanner Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama produk...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      onSubmitted: (v) => kasir.fetchProducts(query: v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _barcodeCtrl,
                      decoration: InputDecoration(
                        hintText: 'Barcode/SKU',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: InkWell(
                          onTap: _openCameraScanner,
                          child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0F3826), size: 18),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      onSubmitted: _scanBarcode,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _openCameraScanner,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3826),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x180F3826),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white, size: 17),
                        SizedBox(width: 4),
                        Text(
                          'Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter Tabs
          if (_categories.isNotEmpty)
            Container(
              height: 42,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedCategoryId = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedCategoryId == null ? const Color(0xFF0F3826) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedCategoryId == null ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedCategoryId == null ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ..._categories.map((cat) {
                    final isSel = _selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedCategoryId = isSel ? null : cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF0F3826) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Main Interactive POS Area: Left 1-Column List Products, Right Real-time Cart
          Expanded(
            child: Row(
              children: [
                // Product List (Left 60%) — Single Column so product names are fully readable!
                Expanded(
                  flex: 6,
                  child: kasir.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada produk',
                                style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(10),
                              itemCount: filteredProducts.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (ctx, i) {
                                final p = filteredProducts[i];
                                final hasMultiUom = p.productUoms != null && p.productUoms!.isNotEmpty;
                                final isAvailable = p.stock > 0;
                                final catIdx = _categories.indexWhere((c) => c.id == p.categoryId);
                                final categoryName = catIdx >= 0 ? _categories[catIdx].name : null;

                                return InkWell(
                                  onTap: isAvailable ? () => _showUomSelectorModal(p) : null,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.white : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isAvailable ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                                      ),
                                      boxShadow: isAvailable
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x040F172A),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Name (full width, clear & legible!)
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                            color: isAvailable ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),

                                        // Category, SKU, and Multi-UOM Badges
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            if (categoryName != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ),
                                            if (hasMultiUom)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFFBEB),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                                ),
                                                child: const Text(
                                                  'MULTI UOM',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFFB45309),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? (p.stock <= p.minStock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5))
                                                    : const Color(0xFFFEF2F2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isAvailable ? 'Stok: ${p.stock} ${p.uom?['symbol'] ?? 'PCS'}' : 'Habis',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: isAvailable
                                                      ? (p.stock <= p.minStock ? const Color(0xFFB45309) : const Color(0xFF065F46))
                                                      : const Color(0xFFDC2626),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Price & Quick Action Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Rp ${AppUtils.formatCurrency(p.price)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                color: isAvailable ? const Color(0xFF0F3826) : const Color(0xFF94A3B8),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: isAvailable ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.add_rounded,
                                                color: isAvailable ? Colors.white : const Color(0xFF94A3B8),
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),

                // Right Cart Sidebar Panel (Right 40%)
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(left: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          color: const Color(0xFFF8FAFC),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              if (kasir.cart.isNotEmpty)
                                GestureDetector(
                                  onTap: () => kasir.clearCart(),
                                  child: const Text('Bersihkan', style: TextStyle(fontSize: 12, color: AppColors.statusError, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.border),

                        // Cart Item List
                        Expanded(
                          child: kasir.cart.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined, size: 40, color: AppColors.textMuted),
                                      SizedBox(height: 8),
                                      Text('Keranjang kosong', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: kasir.cart.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                                  itemBuilder: (ctx, i) {
                                    final item = kasir.cart[i];
                                    final symbol = (item['uomSymbol'] ?? 'pcs').toString().toUpperCase();
                                    final totalItemPrice = (item['price'] as double) * (item['qty'] as int);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['qty']} $symbol x Rp ${AppUtils.formatCurrency(item['price'])}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Rp ${AppUtils.formatCurrency(totalItemPrice)}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () => kasir.updateCartQty(item['key'], -1),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                                                      child: const Icon(Icons.remove, size: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  ),
                                                  InkWell(
                                                    onTap: () => kasir.updateCartQty(item['key'], 1),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                                                      child: const Icon(Icons.add, size: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const Divider(height: 1, color: AppColors.border),

                        // Subtotal & Checkout Action Footer
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(
                                    'Rp ${AppUtils.formatCurrency(kasir.subtotal)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: kasir.cart.isEmpty ? null : () => _showCheckoutModal(kasir),
                                  child: const Text('BAYAR / CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
