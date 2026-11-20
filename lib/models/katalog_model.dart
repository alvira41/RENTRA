
class KatalogModel {
  final int idMobil;
  final int idCategory;
  final String namaMobil;
  final double price;
  final String? image;
  final int totalStock;

  KatalogModel({
    required this.idMobil,
    required this.idCategory,
    required this.namaMobil,
    required this.price,
    this.image,
    required this.totalStock,
  });

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    return KatalogModel(
      idMobil: json['id_mobil'],
      idCategory: json['id_category'],
      namaMobil: json['nama_mobil'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      totalStock: json['total_stock'],
    );
  }

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
