
class MitraModel {
  final int idMitra;
  final String namaPemilik;
  final String namaRental;
  final String alamat;
  final String? noTelepon;
  final String email;
  final String? authUserId;

  MitraModel({
    required this.idMitra,
    required this.namaPemilik,
    required this.namaRental,
    required this.alamat,
    this.noTelepon,
    required this.email,
    this.authUserId,
  });

  factory MitraModel.fromJson(Map<String, dynamic> json) {
    return MitraModel(
      idMitra: json['id_mitra'],
      namaPemilik: json['nama_pemilik'],
      namaRental: json['nama_rental'],
      alamat: json['alamat'],
      noTelepon: json['no_telepon'],
      email: json['email'],
      authUserId: json['auth_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mitra': idMitra,
      'nama_pemilik': namaPemilik,
      'nama_rental': namaRental,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'email': email,
      'auth_user_id': authUserId,
    };
  }
}
