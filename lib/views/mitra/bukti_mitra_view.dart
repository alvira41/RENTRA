import 'package:flutter/material.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';

class BuktiMitraView extends StatelessWidget {
  const BuktiMitraView({super.key});

  Widget _row(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 130,
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 10))),
            value,
          ],
        ),
      );

  Widget _text(String t) =>
      Text(t, style: const TextStyle(color: Colors.white70, fontSize: 10));

  @override
  Widget build(BuildContext context) {
    return MitraPage(
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
                        const Text('Total Pembayaran',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        Text(rupiah(500000),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 8),
                        _row('Status', const StatusBadge('Lunas')),
                        _row('Metode Pembayaran', _text('Transfer')),
                        _row('Tanggal dan Waktu', _text('-')),
                        _row('ID Pembayaran', _text('-')),
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
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.receipt_long,
                              color: Colors.black38, size: 48),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SmallButton(
                label: 'Back', onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }
}