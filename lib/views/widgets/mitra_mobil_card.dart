import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Ambil pertama nilai yang benar-benar ada (bukan null/kosong/'-').
/// Kunci ditambahkan di sini supaya kolom baru dari backend langsung terbaca
/// tanpa perlu mengubah tampilan lagi.
String _isi(Map<String, dynamic>? row, List<String> keys) {
  if (row == null) return '';
  for (final key in keys) {
    final value = row[key];
    if (value == null) continue;
    final teks = value.toString().trim();
    if (teks.isNotEmpty && teks != '-') return teks;
  }
  return '';
}

Map<String, dynamic>? _peta(dynamic value) =>
    value is Map ? value.cast<String, dynamic>() : null;

int _angka(dynamic value) => (value is num ? value : num.tryParse(value?.toString() ?? ''))?.toInt() ?? 0;

class MitraMobilData {
  final int id;
  final String nama;
  final String merk;
  final String nopol;
  final String spesifikasi;
  final String kapasitas;
  final String bbm;
  final String kategori;
  final int harga;
  final int stok;
  final String deskripsi;
  final String? foto;
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
    this.id = 0,
    this.stok = 0,
    this.kategori = '',
    this.deskripsi = '',
    this.foto,
  });

  factory MitraMobilData.fromKatalog(Map<String, dynamic> row) {
    final stok = _angka(row['total_stock']);
    final kategori = _peta(row['category']);
    final transmisi = _isi(kategori, const ['nama', 'name']);
    return MitraMobilData(
      id: _angka(row['id_mobil']),
      nama: _isi(row, const ['nama_mobil']).isEmpty
          ? '-'
          : _isi(row, const ['nama_mobil']),
      merk: _isi(row, const ['merk', 'merk_mobil', 'brand']),
      nopol: _isi(row, const ['nopol', 'no_polisi', 'plat_nomor']),
      spesifikasi: _isi(row, const ['spesifikasi']).isEmpty
          ? transmisi
          : _isi(row, const ['spesifikasi']),
      kapasitas: _isi(
          row, const ['kapasitas', 'kapasitas_penumpang', 'jumlah_kursi']),
      bbm: _isi(row, const ['bbm', 'jenis_bbm', 'bahan_bakar']),
      kategori: transmisi,
      harga: _angka(row['price']) == 0 ? _angka(row['harga']) : _angka(row['price']),
      stok: stok,
      deskripsi: _isi(row, const ['deskripsi', 'keterangan']),
      foto: _isi(row, const ['image', 'gambar', 'foto']).isEmpty
          ? null
          : _isi(row, const ['image', 'gambar', 'foto']),
      status: stok > 0 ? 'Tersedia' : 'Habis',
    );
  }

  factory MitraMobilData.fromKatalogMitra(Map<String, dynamic> row) {
    final stok = _angka(row['total_stock_mitra']);
    final kategori = _peta(row['category']);
    final transmisi = _isi(kategori, const ['nama', 'name']);
    return MitraMobilData(
      id: _angka(row['id_mobil_mitra']),
      nama: _isi(row, const ['nama_mobil_mitra']).isEmpty
          ? '-'
          : _isi(row, const ['nama_mobil_mitra']),
      merk: _isi(row, const ['merk', 'merk_mobil', 'brand']),
      nopol: _isi(row, const ['nopol', 'no_polisi', 'plat_nomor']),
      spesifikasi: _isi(row, const ['spesifikasi']).isEmpty
          ? transmisi
          : _isi(row, const ['spesifikasi']),
      kapasitas: _isi(
          row, const ['kapasitas', 'kapasitas_penumpang', 'jumlah_kursi']),
      bbm: _isi(row, const ['bbm', 'jenis_bbm', 'bahan_bakar']),
      kategori: transmisi,
      harga: _angka(row['price']) == 0 ? _angka(row['harga']) : _angka(row['price']),
      stok: stok,
      deskripsi: _isi(row, const ['deskripsi', 'keterangan']),
      foto: _isi(row, const ['image_mitra', 'image', 'gambar', 'foto']).isEmpty
          ? null
          : _isi(row, const ['image_mitra', 'image', 'gambar', 'foto']),
      status: stok > 0 ? 'Tersedia' : 'Habis',
    );
  }
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
    case 'Habis':
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

  /// Baris hanya muncul kalau datanya benar-benar ada.
  Widget _baris(String label, String value) {
    final teks = value.trim();
    if (teks.isEmpty || teks == '-') return const SizedBox.shrink();
    return _line(label, teks);
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.26;

    Widget gambarCadangan() => Image.asset(
          'assets/images/car1.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: const Color(0xFF1F2937)),
        );

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
                        child: (data.foto == null || data.foto!.isEmpty)
                            ? gambarCadangan()
                            : Image.network(
                                data.foto!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    gambarCadangan(),
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
                    _baris('Merk Mobil', data.merk),
                    _baris('Nomor Polisi', data.nopol),
                    _baris('Spesifikasi', data.spesifikasi),
                    _baris('Kapasitas penumpang', data.kapasitas),
                    _baris('Jenis BBM', data.bbm),
                    _baris('Tipe Transmisi', data.kategori),
                    if (data.harga > 0) ...[
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