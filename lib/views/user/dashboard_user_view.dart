import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

class DashboardUserView extends StatefulWidget {
  const DashboardUserView({super.key});

  @override
  State<DashboardUserView> createState() => _DashboardUserViewState();
}

class _DashboardUserViewState extends State<DashboardUserView> {
  static const _filters = ['Semua', 'Matic', 'Manual'];

  String _filter = 'Semua';

  final List<MitraMobilData> _mobil = [
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N V174 OCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Tersedia'),
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N V174 OCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Tersedia'),
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N V174 OCT',
        spesifikasi: 'Manual',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Tersedia'),
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N V174 OCT',
        spesifikasi: 'Manual',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Disewa'),
  ];

  List<MitraMobilData> get _tampil => _filter == 'Semua'
      ? _mobil
      : _mobil.where((m) => m.spesifikasi == _filter).toList();

  void _pesan(MitraMobilData m) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutView(mobil: m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _tampil;

    return UserPage(
      title: 'KATALOG MOBIL',
      navIndex: 0,
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada mobil untuk tipe ini',
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
                        onPesan: m.status == 'Tersedia' ? () => _pesan(m) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
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
          color: selected ? const Color(0xFFD1D5DB) : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFD1D5DB) : const Color(0x66FFFFFF),
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
                    child: Image.asset(
                      'assets/images/car1.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF1F2937)),
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
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x26FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x80FFFFFF)),
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 9,
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
                _line('Merk Mobil', mobil.merk),
                _line('Nomor Polisi', mobil.nopol),
                _line('Spesifikasi', mobil.spesifikasi),
                _line('Kapasitas penumpang', mobil.kapasitas),
                _line('Jenis BBM', mobil.bbm),
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