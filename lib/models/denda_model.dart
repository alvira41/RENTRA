
class DendaModel {
  final int idDenda;
  final int idOrderDetails;
  final DateTime tanggalKembaliSeharusnya;
  final DateTime? tanggalKembaliAktual;
  final int keterlambatanHari;
  final double dendaPerHari;
  final double totalDenda;

  DendaModel({
    required this.idDenda,
    required this.idOrderDetails,
    required this.tanggalKembaliSeharusnya,
    this.tanggalKembaliAktual,
    required this.keterlambatanHari,
    required this.dendaPerHari,
    required this.totalDenda,
  });

  factory DendaModel.fromJson(Map<String, dynamic> json) {
    return DendaModel(
      idDenda: json['id_denda'],
      idOrderDetails: json['id_order_details'],
      tanggalKembaliSeharusnya:
          DateTime.parse(json['tanggal_kembali_seharusnya']),
      tanggalKembaliAktual:
          json['tanggal_kembali_aktual'] != null
              ? DateTime.parse(json['tanggal_kembali_aktual'])
              : null,
      keterlambatanHari: json['keterlambatan_hari'],
      dendaPerHari: (json['denda_per_hari'] as num).toDouble(),
      totalDenda: (json['total_denda'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_denda': idDenda,
      'id_order_details': idOrderDetails,
      'tanggal_kembali_seharusnya':
          tanggalKembaliSeharusnya.toIso8601String().split('T').first,
      'tanggal_kembali_aktual':
          tanggalKembaliAktual?.toIso8601String().split('T').first,
      'keterlambatan_hari': keterlambatanHari,
      'denda_per_hari': dendaPerHari,
      'total_denda': totalDenda,
    };
  }
}
