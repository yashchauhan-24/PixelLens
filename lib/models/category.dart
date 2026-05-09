class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.description = '',
  });

  final String id;
  final String name;
  final String imageUrl;
  final String description;

  CategoryModel copyWith({String? id, String? name, String? imageUrl, String? description}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
    );
  }
}