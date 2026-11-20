
class AdminModel {
  final int idAdmin;
  final String namaAdmin;
  final String emailAdmin;
  final String? authUserId;

  AdminModel({
    required this.idAdmin,
    required this.namaAdmin,
    required this.emailAdmin,
    this.authUserId,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      idAdmin: json['id_admin'],
      namaAdmin: json['nama_admin'],
      emailAdmin: json['email_admin'],
      authUserId: json['auth_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_admin': idAdmin,
      'nama_admin': namaAdmin,
      'email_admin': emailAdmin,
      'auth_user_id': authUserId,
    };
  }
}
