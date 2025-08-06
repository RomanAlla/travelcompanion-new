import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/error/error_handler.dart';
import 'package:travelcompanion/core/service/supabase_service.dart';
import 'package:travelcompanion/core/utils/string_utils.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';

class RouteCardWidget extends ConsumerStatefulWidget {
  final RouteModel route;
  final Function()? onTap;
  const RouteCardWidget({super.key, required this.route, required this.onTap});

  @override
  ConsumerState<RouteCardWidget> createState() => _RouteCardWidgetState();
}

class _RouteCardWidgetState extends ConsumerState<RouteCardWidget> {
  double? routeRating;
  int? userRoutesCount;

  Future<void> getRouteRating() async {
    final sbService = SupabaseService(Supabase.instance.client);
    try {
      final rating = await sbService.getAvgRating(widget.route.id);
      setState(() {
        routeRating = rating;
      });
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> getUserRoutesCount() async {
    try {
      final count = await ref
          .watch(routeRepositoryProvider)
          .getUserRoutesCount(creatorId: widget.route.creatorId);
      setState(() {
        userRoutesCount = count;
      });
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRouteRating();
      getUserRoutesCount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.route.photoUrls.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: widget.route.photoUrls.isNotEmpty
                        ? Image.network(
                            widget.route.photoUrls.first,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[50],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(height: 300),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.route.routeType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.route.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRatingBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.route.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildCreatorInfo(),
                      const Spacer(),
                      _buildActionButtons(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return routeRating != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16, color: Colors.orangeAccent),
                const SizedBox(width: 4),
                Text(
                  '${routeRating?.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildCreatorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[50],
          backgroundImage: widget.route.creator?.avatarUrl != null
              ? NetworkImage(widget.route.creator!.avatarUrl!)
              : null,
          child: widget.route.creator?.avatarUrl == null
              ? Icon(Icons.person, size: 16, color: Colors.grey[500])
              : null,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.route.creator?.name ?? 'Автор',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Text(
              pluralizeRoute(userRoutesCount ?? 0),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.favorite_border,
          color: Colors.grey[600]!,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.share,
          color: Colors.grey[600]!,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
