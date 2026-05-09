class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    this.categoryId = '',
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String categoryId;

  ProductModel copyWith({String? id, String? name, double? price, String? description, String? image, String? categoryId}) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': image,
        'image': image,
        'categoryId': categoryId,
      };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      image: (map['imageUrl'] ?? map['image']) as String,
      categoryId: (map['categoryId'] as String?) ?? '',
    );
  }
}
