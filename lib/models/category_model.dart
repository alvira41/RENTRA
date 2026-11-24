
class CategoryModel {
  final int idCategory;
  final String nama;

  CategoryModel({
    required this.idCategory,
    required this.nama,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      idCategory: json['id_category'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category': idCategory,
      'nama': nama,
    };
  }
}
