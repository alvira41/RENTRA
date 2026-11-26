import 'package:flutter/material.dart';
import '../../controllers/katalog_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import 'mitra_car_form_view.dart';

class DashboardMitraView extends StatefulWidget {
  const DashboardMitraView({super.key});

  @override
  State<DashboardMitraView> createState() => _DashboardMitraViewState();
}

class _DashboardMitraViewState extends State<DashboardMitraView> {
  late final KatalogController _katalog;
  bool _siap = false;

  @override
  void initState() {
    super.initState();
    _katalog = AppControllers.of(context).katalog;
    _muat();
  }

  Future<void> _muat() async {
    final okKategori = await _katalog.loadCategories();
    final errKategori = _katalog.errorMessage;
    final okMobil = await _katalog.loadKatalogMitra();
    final errMobil = _katalog.errorMessage;
    if (!mounted) return;
    if (!okMobil) {
      _pesan(errMobil ?? 'Data mobil gagal dimuat');
    } else if (!okKategori) {
      _pesan(errKategori ?? 'Kategori gagal dimuat');
    }
    setState(() => _siap = true);
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  MitraMobilData _tampilan(Map<String, dynamic> row) =>
      MitraMobilData.fromKatalogMitra(row);

  Future<void> _edit(Map<String, dynamic> row) async {
    final diubah = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MitraCarFormView(isEdit: true, mobil: row),
      ),
    );
    if (diubah == true && mounted) _muat();
  }

  Future<void> _hapus(Map<String, dynamic> row) async {
    final nama = row['nama_mobil_mitra']?.toString() ?? 'mobil ini';
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F1621),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        title: const Text(
          'Hapus mobil?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Data $nama akan dihapus.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final berhasil = await _katalog
        .deleteKatalogMitra((row['id_mobil_mitra'] as num).toInt());
    if (!mounted) return;
    _pesan(berhasil
        ? 'Mobil dihapus'
        : (_katalog.errorMessage ?? 'Gagal menghapus mobil'));
  }

  @override
  Widget build(BuildContext context) {
    return MitraPage(
      title: 'DASHBOARD MITRA',
      navIndex: 0,
      child: ListenableBuilder(
        listenable: _katalog,
        builder: (context, _) {
          if (!_siap) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = _katalog.katalogMitra;
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Belum ada mobil',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SmallButton(
                    label: 'Muat ulang',
                    icon: Icons.refresh,
                    onTap: () {
                      setState(() => _siap = false);
                      _muat();
                    },
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _muat,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = data[index];
                return MitraMobilCard(
                  data: _tampilan(row),
                  actions: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmallButton(
                        label: 'Edit',
                        icon: Icons.edit,
                        onTap: () => _edit(row),
                      ),
                      const SizedBox(width: 6),
                      SmallButton(
                        label: 'Hapus',
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        onTap: () => _hapus(row),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}