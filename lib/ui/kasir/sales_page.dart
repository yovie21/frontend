import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../data/models/models.dart';
import '../../../providers/kasir_provider.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _searchCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KasirProvider>().fetchProducts();
    });
  }

  void _scanBarcode(String code) {
    final kasir = context.read<KasirProvider>();
    final p = kasir.products
        .where((e) => (e.barcode ?? '').trim() == code.trim() || e.sku.trim() == code.trim())
        .firstOrNull;
    if (p != null) {
      _showUomSelectorModal(p);
      _barcodeCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk / barcode tidak ditemukan')),
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

  void _showCheckoutModal(KasirProvider kasir) {
    final cashCtrl = TextEditingController();
    final discCtrl = TextEditingController(text: '0');
    var method = 'tunai';
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
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: !canPay
                          ? null
                          : () async {
                              final s = await kasir.checkout(cash, discount: disc, paymentMethod: method);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s != null ? 'Transaksi ${s.nota} berhasil' : (kasir.errorMessage ?? 'Gagal transaksi'))),
                              );
                            },
                      child: const Text('PROSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kasir POS'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Search & Barcode Scanner Header Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    onSubmitted: (v) => kasir.fetchProducts(query: v),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _barcodeCtrl,
                    decoration: InputDecoration(
                      hintText: 'Barcode/SKU',
                      prefixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    onSubmitted: _scanBarcode,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Main Interactive POS Area: Left Grid Products, Right Real-time Cart
          Expanded(
            child: Row(
              children: [
                // Product Grid (Left 60%)
                Expanded(
                  flex: 6,
                  child: kasir.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : kasir.products.isEmpty
                          ? const Center(child: Text('Tidak ada produk', style: TextStyle(color: AppColors.textSecondary)))
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.95,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: kasir.products.length,
                              itemBuilder: (ctx, i) {
                                final p = kasir.products[i];
                                final hasMultiUom = p.productUoms != null && p.productUoms!.isNotEmpty;
                                final isAvailable = p.stock > 0;

                                return InkWell(
                                  onTap: isAvailable ? () => _showUomSelectorModal(p) : null,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.white : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.border),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                              ),
                                            ),
                                            if (hasMultiUom)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text('MULTI UOM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rp ${AppUtils.formatCurrency(p.price)}',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Stok: ${p.stock} ${p.uom?['symbol'] ?? 'PCS'}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isAvailable ? AppColors.textSecondary : AppColors.statusError,
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
