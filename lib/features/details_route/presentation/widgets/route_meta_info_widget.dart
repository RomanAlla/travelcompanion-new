import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/utils/string_utils.dart';

class RouteMetaInfoWidget extends StatelessWidget {
  final double rating;
  final int reviewsCount;

  const RouteMetaInfoWidget({
    super.key,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 6.0,
      alignment: WrapAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1,
              ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 14,
                color: Colors.orange.shade300,
              ),
              const SizedBox(width: 6),
              Text(
                StringUtils.pluralizeReviews(reviewsCount),
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
