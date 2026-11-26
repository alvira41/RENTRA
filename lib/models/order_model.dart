
class OrderModel {
  final int idOrder;
  final String idUser;
  final String? idAdmin;
  final String transactionCode;
  final String status;
  final double totalPrice;
  final String? buktiPayment;

  OrderModel({
    required this.idOrder,
    required this.idUser,
    this.idAdmin,
    required this.transactionCode,
    required this.status,
    required this.totalPrice,
    this.buktiPayment,
  });

  // Mengubah data JSON dari Supabase menjadi OrderModel.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idOrder: (json['id_order'] as num).toInt(),
      idUser: json['id_user'].toString(),
      idAdmin: json['id_admin']?.toString(),
      transactionCode: json['transaction_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      totalPrice: (json['total_price'] as num).toDouble(),
      buktiPayment: json['bukti_payment']?.toString(),
    );
  }

  // Mengubah OrderModel menjadi JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id_order': idOrder,
      'id_user': idUser,
      'id_admin': idAdmin,
      'transaction_code': transactionCode,
      'status': status,
      'total_price': totalPrice,
      'bukti_payment': buktiPayment,
    };
  }
}
