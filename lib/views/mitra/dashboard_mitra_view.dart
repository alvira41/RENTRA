import 'package:flutter/material.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/supply_controller.dart';
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
  late final SupplyController _supply;
  late final String? _idMitra;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final controllers = AppControllers.of(context);
    _katalog = controllers.katalog;
    _supply = controllers.supply;
    _idMitra = controllers.auth.idMitra;
    _muat();
  }

  Future<void> _muat() async {
    await Future.wait([
      _katalog.loadKatalogMitra(),
      _supply.loadSupplies(idMitra: _idMitra),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<MitraMobilData> get _mobil => _katalog.katalogMitra
      .map((row) => MitraMobilData.fromKatalogMitra(row))
      .toList();

  Future<void> _tambah() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MitraCarFormView()),
    );
    if (ok == true) _muat();
  }

  Future<void> _edit(MitraMobilData mobil) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MitraCarFormView(isEdit: true, mobil: mobil),
      ),
    );
    if (ok == true) _muat();
  }

  Future<void> _hapus(MitraMobilData mobil) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Mobil'),
        content: Text('Hapus ${mobil.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final sukses = await _katalog.deleteKatalogMitra(mobil.id);
    if (!mounted) return;
    _pesan(sukses
        ? 'Mobil dihapus'
        : _katalog.errorMessage ?? 'Mobil gagal dihapus');
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final pending = _supply.supplies
        .where((s) => s['status'] == 'pending')
        .length;

    return MitraPage(
      title: 'DASHBOARD MITRA',
      navIndex: 0,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x40FFFFFF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$pending supply menunggu konfirmasi',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _tambah,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Tambah Mobil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListenableBuilder(
              listenable: _katalog,
              builder: (context, _) {
                final mobil = _mobil;
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (mobil.isEmpty) {
                  return const Center(
                    child: Text('Belum ada mobil',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                  );
                }
                return ListView.separated(
                  itemCount: mobil.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => MitraMobilCard(
                    data: mobil[i],
                    actions: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SmallButton(
                          label: 'Edit',
                          icon: Icons.edit,
                          onTap: () => _edit(mobil[i]),
                        ),
                        const SizedBox(width: 6),
                        SmallButton(
                          label: 'Hapus',
                          icon: Icons.delete_outline,
                          color: const Color(0xFFEF4444),
                          onTap: () => _hapus(mobil[i]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
