
class SupplyModel {
  final int idSupply;
  final int idOrder;
  final int idMitra;
  final int? idAdmin;
  final DateTime? tanggalSupply;
  final DateTime? tanggalKembali;
  final String status;

  SupplyModel({
    required this.idSupply,
    required this.idOrder,
    required this.idMitra,
    this.idAdmin,
    this.tanggalSupply,
    this.tanggalKembali,
    required this.status,
  });

  factory SupplyModel.fromJson(Map<String, dynamic> json) {
    return SupplyModel(
      idSupply: json['id_supply'],
      idOrder: json['id_order'],
      idMitra: json['id_mitra'],
      idAdmin: json['id_admin'],
      tanggalSupply: json['tanggal_supply'] != null
          ? DateTime.parse(json['tanggal_supply'])
          : null,
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.parse(json['tanggal_kembali'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_supply': idSupply,
      'id_order': idOrder,
      'id_mitra': idMitra,
      'id_admin': idAdmin,
      'tanggal_supply':
          tanggalSupply?.toIso8601String().split('T').first,
      'tanggal_kembali':
          tanggalKembali?.toIso8601String().split('T').first,
      'status': status,
    };
  }
}
