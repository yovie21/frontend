import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/modern_widgets.dart';

class UomPage extends StatefulWidget {
  const UomPage({super.key});

  @override
  State<UomPage> createState() => _UomPageState();
}

class _UomPageState extends State<UomPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initAdminData();
    });
  }

  void _showForm({Uom? uom}) {
    final nameCtrl = TextEditingController(text: uom?.name ?? '');
    final symbolCtrl = TextEditingController(text: uom?.symbol ?? '');
    bool isSaving = false;

    const quickUnits = [
      ('PCS', 'Pieces / Butir'),
      ('DUS', 'Kardus / Karton'),
      ('PACK', 'Pack / Bungkus'),
      ('RNT', 'Renceng'),
      ('BTL', 'Botol'),
      ('KG', 'Kilogram'),
      ('GR', 'Gram'),
      ('LTR', 'Liter'),
      ('KRT', 'Karton'),
      ('SLOP', 'Slop'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          final previewSymbol = symbolCtrl.text.trim().isEmpty ? 'PCS' : symbolCtrl.text.trim().toUpperCase();
          final previewName = nameCtrl.text.trim().isEmpty ? 'Pieces' : nameCtrl.text.trim();

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.straighten_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        uom == null ? 'Tambah Satuan (UOM)' : 'Edit Satuan (UOM)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Live Preview Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F3826), Color(0xFF1B5E3C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x180F3826),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              previewSymbol.length > 4 ? previewSymbol.substring(0, 3) : previewSymbol,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PRATINJAU TAMPILAN',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                              ),
                              Text(
                                previewName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                'Simbol: $previewSymbol',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Suggestion Chips
                  const Text(
                    'PILIHAN CEPAT SATUAN TOKO:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickUnits.map((u) {
                      final isSelected = symbolCtrl.text.toUpperCase() == u.$1;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setM(() {
                            symbolCtrl.text = u.$1;
                            nameCtrl.text = u.$2;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F3826) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F3826) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            '${u.$1} (${u.$2.split(' ').first})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: symbolCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Simbol Singkat *',
                      hintText: 'Contoh: PCS, DUS, KRT, BTL, KG',
                      prefixIcon: Icon(Icons.short_text_rounded),
                    ),
                    onChanged: (_) => setM(() {}),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Satuan *',
                      hintText: 'Contoh: Pieces, Kardus, Botol, Kilogram',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    onChanged: (_) => setM(() {}),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3826),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final symbol = symbolCtrl.text.trim().toUpperCase();
                            if (name.isEmpty) return;
                            setM(() => isSaving = true);

                            final admin = context.read<AdminProvider>();
                            Navigator.pop(ctx);
                            bool ok = uom == null
                                ? await admin.createUom(name, symbol: symbol.isEmpty ? null : symbol)
                                : await admin.updateUom(uom.id, name, symbol: symbol.isEmpty ? null : symbol);
                            if (mounted && !ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text(admin.errorMessage ?? 'Gagal menyimpan satuan')),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan Satuan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Uom u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Satuan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
          'Yakin ingin menghapus satuan "${u.name} (${u.symbol ?? '-'})"?',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminProvider>().deleteUom(u.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  _UomPalette _getUomPalette(String symbol) {
    final s = symbol.toUpperCase().trim();
    if (s == 'DUS' || s == 'KRT' || s == 'SLOP' || s == 'PACK' || s == 'RNT' || s == 'KOTAK') {
      return _UomPalette(
        gradient: const [Color(0xFF92400E), Color(0xFFD97706)],
        label: 'Grosir / Paket',
        badgeBg: const Color(0xFFFFFBEB),
        badgeFg: const Color(0xFFB45309),
        badgeBorder: const Color(0xFFFDE68A),
      );
    }
    if (s == 'KG' || s == 'GR' || s == 'LTR' || s == 'ML' || s == 'MTR') {
      return _UomPalette(
        gradient: const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        label: 'Ukuran / Volume',
        badgeBg: const Color(0xFFEFF6FF),
        badgeFg: const Color(0xFF1D4ED8),
        badgeBorder: const Color(0xFFBFDBFE),
      );
    }
    return _UomPalette(
      gradient: const [Color(0xFF0F3826), Color(0xFF1B5E3C)],
      label: 'Satuan Eceran',
      badgeBg: const Color(0xFFECFDF5),
      badgeFg: const Color(0xFF065F46),
      badgeBorder: const Color(0xFFA7F3D0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final uoms = admin.uoms.where((u) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || (u.symbol ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Text(
              'Satuan Ukuran (UOM)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                '${uoms.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF0F3826),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Satuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Cari satuan (nama atau simbol)...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // Overview Stats Strip
          if (_searchQuery.isEmpty && admin.uoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Builder(builder: (context) {
                final usedCount = admin.uoms.where((u) {
                  return admin.products.any((p) => p.uomId == u.id || (p.productUoms != null && p.productUoms!.any((pu) => pu['uomId'] == u.id)));
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.straighten_rounded, color: Color(0xFF2563EB), size: 16),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Satuan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                Text(
                                  '${admin.uoms.length}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Aktif Digunakan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                Text(
                                  '$usedCount Satuan',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

          // UOM List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => admin.fetchUoms(),
              child: uoms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.straighten_outlined, size: 32, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada satuan sesuai "$_searchQuery"'
                                : 'Belum ada satuan yang dibuat',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: uoms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final u = uoms[i];
                        final symbol = (u.symbol ?? u.name).toUpperCase();
                        
                        // Count products using this UOM (either as base UOM or in multi-uom)
                        final usedCount = admin.products.where((p) {
                          if (p.uomId == u.id) return true;
                          if (p.productUoms != null) {
                            return p.productUoms!.any((pu) => pu['uomId'] == u.id);
                          }
                          return false;
                        }).length;
                        final palette = _getUomPalette(symbol);

                        return ModernCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Bold Monogram Badge Container
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: palette.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: palette.gradient.first.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    symbol.length > 4 ? symbol.substring(0, 3) : symbol,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name & Usage Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: palette.badgeBg,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: palette.badgeBorder),
                                          ),
                                          child: Text(
                                            palette.label,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: palette.badgeFg,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$usedCount Produk',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Action Buttons
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _showForm(uom: u),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0F3826)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _confirmDelete(context, u),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UomPalette {
  final List<Color> gradient;
  final String label;
  final Color badgeBg;
  final Color badgeFg;
  final Color badgeBorder;

  _UomPalette({
    required this.gradient,
    required this.label,
    required this.badgeBg,
    required this.badgeFg,
    required this.badgeBorder,
  });
}
