import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

class ReviewService {
  ReviewService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _reviewsRef(String productId) =>
      _firestore.collection('products').doc(productId).collection('reviews');

  Future<List<ReviewModel>> fetchReviews(String productId) async {
    final snapshot = await _reviewsRef(productId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => ReviewModel.fromMap({...d.data(), 'id': d.id})).toList();
  }

  Future<ReviewSummary> fetchSummary(String productId) async {
    final snapshot = await _reviewsRef(productId).get();
    if (snapshot.docs.isEmpty) return ReviewSummary(productId: productId, average: 0.0, count: 0);
    var sum = 0;
    for (final d in snapshot.docs) {
      sum += (d.data()['rating'] as num?)?.toInt() ?? 0;
    }
    final count = snapshot.docs.length;
    final avg = count == 0 ? 0.0 : sum / count;
    return ReviewSummary(productId: productId, average: avg, count: count);
  }

  Future<void> addReview(ReviewModel review) async {
    await _reviewsRef(review.productId).add(review.toMap());
  }
}
