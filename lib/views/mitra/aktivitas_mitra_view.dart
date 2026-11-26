import 'package:flutter/material.dart';
import '../../controllers/supply_controller.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';
import 'bukti_mitra_view.dart';

class AktivitasMitraView extends StatefulWidget {
  const AktivitasMitraView({super.key});

  @override
  State<AktivitasMitraView> createState() => _AktivitasMitraViewState();
}

class _AktivitasMitraViewState extends State<AktivitasMitraView> {
  late final SupplyController _supply;
  late final String? _idMitra;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final controllers = AppControllers.of(context);
    _supply = controllers.supply;
    _idMitra = controllers.auth.idMitra;
    _muat();
  }

  Future<void> _muat() async {
    final ok = await _supply.loadSupplies(idMitra: _idMitra);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) _pesan(_supply.errorMessage ?? 'Gagal memuat aktivitas');
  }

  Future<void> _kembalikan(int id) async {
    final ok = await _supply.markReturned(id);
    if (!mounted) return;
    _pesan(ok ? 'Supply ditandai kembali' : _supply.errorMessage ?? 'Gagal');
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _label(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'returned':
        return 'Selesai';
      default:
        return status ?? '-';
    }
  }

  Widget _chip(String label, String value) => Expanded(
        child: GlassCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              Text(value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final data = _supply.supplies;
    final aktif = data.where((s) => s['status'] == 'approved').length;

    return MitraPage(
      title: 'AKTIVITAS',
      navIndex: 3,
      child: Column(
        children: [
          Row(
            children: [
              _chip('Total Supply', '${data.length}'),
              const SizedBox(width: 8),
              _chip('Supply Aktif', '$aktif'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListenableBuilder(
              listenable: _supply,
              builder: (context, _) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Belum ada aktivitas supply',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                  );
                }
                return ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final row = data[i];
                    final id = (row['id_supply'] as num?)?.toInt() ?? 0;
                    final status = row['status']?.toString();
                    return MitraMobilCard(
                      data: MitraMobilData(
                        nama: 'Supply #$id',
                        merk: row['mitra']?['nama_rental']?.toString() ?? '',
                        nopol: '',
                        spesifikasi: '',
                        kapasitas: '',
                        bbm: '',
                        harga: 0,
                        status: _label(status),
                      ),
                      actions: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal supply : ${row['tanggal_supply'] ?? '-'}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SmallButton(
                                label: 'Lihat Bukti',
                                icon: Icons.receipt_long,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BuktiMitraView(idSupply: id),
                                  ),
                                ),
                              ),
                              if (status == 'approved') ...[
                                const SizedBox(width: 6),
                                SmallButton(
                                  label: 'Kembalikan',
                                  icon: Icons.assignment_return,
                                  color: const Color(0xFF4ADE80),
                                  onTap: () => _kembalikan(id),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
