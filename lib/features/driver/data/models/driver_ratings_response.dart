class DriverReviewItem {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String reviewerName;

  const DriverReviewItem({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.reviewerName,
  });

  factory DriverReviewItem.fromJson(Map<String, dynamic> json) {
    return DriverReviewItem(
      id: json['id'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      reviewerName: json['reviewerName'] as String? ?? 'Passenger',
    );
  }
}

class DriverRatingsResponse {
  final double averageRating;
  final int totalReviews;
  final List<DriverReviewItem> reviews;

  const DriverRatingsResponse({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory DriverRatingsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['reviews'] as List?) ?? [];
    return DriverRatingsResponse(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      reviews: list
          .map((item) => DriverReviewItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
