
class AppUserModel {
  final int idUser;
  final String namaUser;
  final String? jenisKelamin;
  final DateTime? tanggalLahir;
  final String? alamat;
  final String? noKtp;
  final String? noTeleponUser;
  final String? fotoKtp;
  final String? authUserId;

  AppUserModel({
    required this.idUser,
    required this.namaUser,
    this.jenisKelamin,
    this.tanggalLahir,
    this.alamat,
    this.noKtp,
    this.noTeleponUser,
    this.fotoKtp,
    this.authUserId,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      idUser: json['id_user'],
      namaUser: json['nama_user'],
      jenisKelamin: json['jenis_kelamin'],
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'])
          : null,
      alamat: json['alamat'],
      noKtp: json['no_ktp'],
      noTeleponUser: json['no_telepon_user'],
      fotoKtp: json['foto_ktp'],
      authUserId: json['auth_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama_user': namaUser,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir':
          tanggalLahir?.toIso8601String().split('T').first,
      'alamat': alamat,
      'no_ktp': noKtp,
      'no_telepon_user': noTeleponUser,
      'foto_ktp': fotoKtp,
      'auth_user_id': authUserId,
    };
  }
}
