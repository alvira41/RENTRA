import 'package:flutter/material.dart';
import '../../controllers/katalog_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

class DashboardUserView extends StatefulWidget {
  const DashboardUserView({super.key});

  @override
  State<DashboardUserView> createState() => _DashboardUserViewState();
}

class _DashboardUserViewState extends State<DashboardUserView> {
  late final KatalogController _katalog;
  String _filter = 'Semua';

  List<String> get _filters => [
        'Semua',
        for (final k in _katalog.categories) k['nama']?.toString() ?? '-',
      ];

  List<MitraMobilData> get _mobil => _katalog.katalog
      .map((row) => MitraMobilData.fromKatalog(row))
      .toList();

  List<MitraMobilData> get _tampil => _filter == 'Semua'
      ? _mobil
      : _mobil.where((m) => m.kategori == _filter).toList();

  @override
  void initState() {
    super.initState();
    _katalog = AppControllers.of(context).katalog;
    _muat();
  }

  Future<void> _muat() async {
    await _katalog.loadCategories();
    final ok = await _katalog.loadKatalog();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_katalog.errorMessage ?? 'Gagal memuat katalog')),
      );
    }
  }

  void _pesan(MitraMobilData m) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutView(mobil: m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _katalog,
      builder: (context, _) {
        final data = _tampil;
        return UserPage(
          title: 'KATALOG MOBIL',
          navIndex: 0,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final f in _filters)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _FilterChip(
                          label: f,
                          selected: _filter == f,
                          onTap: () => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: data.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada mobil untuk kategori ini',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final m = data[index];
                          return _UserCarCard(
                            mobil: m,
                            onPesan:
                                m.status == 'Tersedia' ? () => _pesan(m) : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.button : const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.button : const Color(0x40FFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF111827) : AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _UserCarCard extends StatelessWidget {
  const _UserCarCard({required this.mobil, required this.onPesan});

  final MitraMobilData mobil;
  final VoidCallback? onPesan;

  Widget _line(String label, String value) => Text(
        '$label : $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9,
          height: 1.4,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.26;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: imageWidth,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                      child: (mobil.foto == null || mobil.foto!.isEmpty)
                          ? Image.asset(
                              'assets/images/car1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xFF1F2937)),
                            )
                          : Image.network(
                              mobil.foto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/car1.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: const Color(0xFF1F2937)),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 6),
                StatusBadge(mobil.status, expand: true),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onPesan,
                  child: Opacity(
                    opacity: onPesan == null ? 0.4 : 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F6FB8).withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4F6FB8)),
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mobil.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (mobil.kategori.isNotEmpty)
                  _line('Kategori', mobil.kategori),
                _line('Stok', '${mobil.stok}'),
                const SizedBox(height: 4),
                const Text(
                  'Harga tidak termasuk BBM',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                Text(
                  '${rupiah(mobil.harga)} / hari',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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