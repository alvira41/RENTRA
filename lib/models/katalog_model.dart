
class KatalogModel {
  final int idMobil;
  final int idCategory;
  final String namaMobil;
  final double price;
  final String? image;
  final int totalStock;
  final String? namaCategory;

  KatalogModel({
    required this.idMobil,
    required this.idCategory,
    required this.namaMobil,
    required this.price,
    this.image,
    required this.totalStock,
    this.namaCategory,
  });

  // ==========================================
  // FROM JSON
  // ==========================================

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];

    String? categoryName;

    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['nama']?.toString();
    } else if (categoryData is List && categoryData.isNotEmpty) {
      categoryName = categoryData.first['nama']?.toString();
    }

    return KatalogModel(
      idMobil: (json['id_mobil'] as num).toInt(),
      idCategory: (json['id_category'] as num).toInt(),
      namaMobil: json['nama_mobil']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image']?.toString(),
      totalStock: (json['total_stock'] as num).toInt(),
      namaCategory: categoryName,
    );
  }

  // ==========================================
  // TO JSON
  // ==========================================

  Map<String, dynamic> toJson() {
    return {
      'id_mobil': idMobil,
      'id_category': idCategory,
      'nama_mobil': namaMobil,
      'price': price,
      'image': image,
      'total_stock': totalStock,
    };
  }
}
