import 'package:flutter/foundation.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class ReviewController extends ChangeNotifier {
  ReviewController(this._reviewService) : _summaries = {}, _reviews = {};

  final ReviewService _reviewService;
  final Map<String, ReviewSummary> _summaries;
  final Map<String, List<ReviewModel>> _reviews;

  ReviewSummary? summaryFor(String productId) => _summaries[productId];
  List<ReviewModel> reviewsFor(String productId) => List.unmodifiable(_reviews[productId] ?? []);

  Future<void> loadSummary(String productId) async {
    final s = await _reviewService.fetchSummary(productId);
    _summaries[productId] = s;
    notifyListeners();
  }

  Future<void> loadReviews(String productId) async {
    final list = await _reviewService.fetchReviews(productId);
    _reviews[productId] = list;
    notifyListeners();
  }

  Future<void> submitReview(ReviewModel review) async {
    await _reviewService.addReview(review);
    await loadReviews(review.productId);
    await loadSummary(review.productId);
  }
}
