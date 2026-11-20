/// Helper format tampilan & konversi data. Tanpa package tambahan.
class Formatter {
  /// 1500000 -> "Rp 1.500.000"
  static String rupiah(num? value) {
    final n = (value ?? 0).round();
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${n < 0 ? '-' : ''}Rp $buf';
  }

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// DateTime -> "10 Nov 2026"
  static String tanggal(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  /// "2026-11-10" -> "10 Nov 2026"
  static String tanggalDariString(String? iso) =>
      tanggal(iso == null ? null : DateTime.tryParse(iso));

  /// DateTime -> "2026-11-10" (format yang diterima database)
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Jumlah hari sewa (minimal 1), sama dengan perhitungan di server.
  static int jumlahHari(DateTime pinjam, DateTime kembali) {
    final d = kembali.difference(pinjam).inDays;
    return d < 1 ? 1 : d;
  }

  /// 'pending' -> 'Menunggu', dst. Untuk label status order.
  static String statusOrder(String? s) => switch (s) {
        'pending' => 'Menunggu',
        'confirmed' => 'Dikonfirmasi',
        'rejected' => 'Ditolak',
        'ongoing' => 'Sedang Disewa',
        'completed' => 'Selesai',
        'cancelled' => 'Dibatalkan',
        _ => s ?? '-',
      };

  static String statusSupply(String? s) => switch (s) {
        'pending' => 'Menunggu',
        'approved' => 'Disetujui',
        'rejected' => 'Ditolak',
        'returned' => 'Dikembalikan',
        _ => s ?? '-',
      };
}