
class OrderModel {
  final int idOrder;
  final int idUser;
  final int? idAdmin;
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idOrder: json['id_order'],
      idUser: json['id_user'],
      idAdmin: json['id_admin'],
      transactionCode: json['transaction_code'],
      status: json['status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      buktiPayment: json['bukti_payment'],
    );
  }

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
