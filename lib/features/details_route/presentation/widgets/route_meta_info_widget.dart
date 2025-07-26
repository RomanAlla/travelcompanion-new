import 'package:flutter/material.dart';
import 'package:travelcompanion/core/utils/string_utils.dart';

class RouteMetaInfoWidget extends StatelessWidget {
  final double rating;
  final int reviewsCount;
  final String routeType;

  const RouteMetaInfoWidget({
    super.key,
    required this.rating,
    required this.reviewsCount,
    required this.routeType,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                pluralizeReviews(reviewsCount),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 30,
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              routeType,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
