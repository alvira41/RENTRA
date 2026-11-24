
class KatalogMitraModel {
  final int idMobilMitra;
  final int idMitra;
  final int? idCategoryMitra;
  final String namaMobilMitra;
  final String? imageMitra;
  final int totalStockMitra;

  KatalogMitraModel({
    required this.idMobilMitra,
    required this.idMitra,
    this.idCategoryMitra,
    required this.namaMobilMitra,
    this.imageMitra,
    required this.totalStockMitra,
  });

  // Mengubah JSON menjadi objek Dart
  factory KatalogMitraModel.fromJson(Map<String, dynamic> json) {
    return KatalogMitraModel(
      idMobilMitra: json['id_mobil_mitra'],
      idMitra: json['id_mitra'],
      idCategoryMitra: json['id_category_mitra'],
      namaMobilMitra: json['nama_mobil_mitra'],
      imageMitra: json['image_mitra'],
      totalStockMitra: json['total_stock_mitra'],
    );
  }

  // Mengubah objek Dart menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id_mobil_mitra': idMobilMitra,
      'id_mitra': idMitra,
      'id_category_mitra': idCategoryMitra,
      'nama_mobil_mitra': namaMobilMitra,
      'image_mitra': imageMitra,
      'total_stock_mitra': totalStockMitra,
    };
  }
}
