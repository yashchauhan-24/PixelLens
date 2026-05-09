class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: (map['id'] as String?) ?? '',
      productId: (map['productId'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      userName: (map['userName'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: (map['comment'] as String?) ?? '',
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewSummary {
  const ReviewSummary({required this.productId, required this.average, required this.count});

  final String productId;
  final double average;
  final int count;
}
