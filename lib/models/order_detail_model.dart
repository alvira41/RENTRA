
class OrderDetailModel {
  final int idOrderDetails;
  final int idOrder;
  final int idMobil;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final double subtotal;

  OrderDetailModel({
    required this.idOrderDetails,
    required this.idOrder,
    required this.idMobil,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.subtotal,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      idOrderDetails: json['id_order_details'],
      idOrder: json['id_order'],
      idMobil: json['id_mobil'],
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: DateTime.parse(json['tanggal_kembali']),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_order_details': idOrderDetails,
      'id_order': idOrder,
      'id_mobil': idMobil,
      'tanggal_pinjam':
          tanggalPinjam.toIso8601String().split('T').first,
      'tanggal_kembali':
          tanggalKembali.toIso8601String().split('T').first,
      'subtotal': subtotal,
    };
  }
}
