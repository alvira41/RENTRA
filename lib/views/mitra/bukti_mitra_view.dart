import 'package:flutter/material.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';

class BuktiMitraView extends StatelessWidget {
  const BuktiMitraView({super.key, this.idSupply, this.supply});

  final int? idSupply;
  final Map<String, dynamic>? supply;

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final argsMap = args is Map<String, dynamic> ? args : null;
    final argsId = args is int
        ? args
        : argsMap == null
            ? null
            : (argsMap['id_supply'] as num?)?.toInt();
    final id = idSupply ?? argsId;
    final row = supply ?? argsMap;
    final data = row ?? AppControllers.of(context).supply.supplies.where((s) {
          final sid = (s['id_supply'] as num?)?.toInt();
          return id != null && sid == id;
        }).firstOrNull;
    final status = data?['status']?.toString();

    return MitraPage(
      title: 'BUKTI SUPPLY',
      showBack: true,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Supply',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _row('ID Supply', _text('#${id ?? '-'}')),
                        _row('Status', StatusBadge(_label(status))),
                        _row('Tanggal Supply',
                            _text(data?['tanggal_supply']?.toString() ?? '-')),
                        _row(
                          'Tanggal Kembali',
                          _text(data?['tanggal_kembali']?.toString() ?? '-'),
                        ),
                        _row('ID Order',
                            _text(data?['id_order']?.toString() ?? '-')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bukti Pembayaran',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.receipt_long,
                              color: Colors.black38, size: 48),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bukti pembayaran tersedia pada detail order terkait.',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
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
    );
  }

  Widget _row(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
            Expanded(child: value),
          ],
        ),
      );

  Widget _text(String t) =>
      Text(t, style: const TextStyle(color: Colors.white70, fontSize: 10));
}
