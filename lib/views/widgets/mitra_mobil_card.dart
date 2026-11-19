import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MitraMobilData {
  final String nama;
  final String merk;
  final String nopol;
  final String spesifikasi;
  final String kapasitas;
  final String bbm;
  final int harga;
  final String deskripsi;
  String status;

  MitraMobilData({
    required this.nama,
    required this.merk,
    required this.nopol,
    required this.spesifikasi,
    required this.kapasitas,
    required this.bbm,
    required this.harga,
    required this.status,
    this.deskripsi = '',
  });
}

String rupiah(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp.$buf';
}

Color statusColor(String status) {
  switch (status) {
    case 'Tersedia':
    case 'Diterima':
    case 'Selesai':
    case 'Lunas':
      return const Color(0xFF4ADE80);
    case 'Ditolak':
      return const Color(0xFFEF4444);
    case 'Menunggu':
      return const Color(0xFFFB923C);
    default:
      return const Color(0xFF60A5FA);
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool expand;
  const StatusBadge(this.status, {super.key, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      alignment: expand ? Alignment.center : null,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class MitraMobilCard extends StatelessWidget {
  final MitraMobilData data;
  final Widget? actions;

  const MitraMobilCard({super.key, required this.data, this.actions});

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
      child: Column(
        children: [
          Row(
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
                    StatusBadge(data.status, expand: true),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _line('Merk Mobil', data.merk),
                    _line('Nomor Polisi', data.nopol),
                    _line('Spesifikasi', data.spesifikasi),
                    _line('Kapasitas penumpang', data.kapasitas),
                    _line('Jenis BBM', data.bbm),
                    const SizedBox(height: 4),
                    const Text(
                      'Harga tidak termasuk BBM',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                    Text(
                      '${rupiah(data.harga)} / hari',
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
          if (actions != null) ...[
            const SizedBox(height: 8),
            actions!,
          ],
        ],
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;

  const SmallButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF4F6FB8),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final aktif = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: aktif ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: AppColors.textPrimary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}