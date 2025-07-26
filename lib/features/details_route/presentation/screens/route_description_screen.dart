import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_content.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/bottom_sheet.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';

@RoutePage()
class RouteDescriptionScreen extends ConsumerStatefulWidget {
  final RouteModel route;
  final String routeId;

  const RouteDescriptionScreen({
    super.key,
    required this.routeId,
    required this.route,
  });

  @override
  ConsumerState<RouteDescriptionScreen> createState() => _MyshiState();
}

class _MyshiState extends ConsumerState<RouteDescriptionScreen> {
  late final List<Widget> myItems;
  int currentIndex = 0;
  List<CommentModel>? commentsList;
  int? commentsCount;
  double? averageRating;
  int? userRoutesCount;
  double? averageUserRoutesRating;
  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return BottomSheetWidget(route: widget.route);
      },
    );
  }

  Future<void> getCommentsCount() async {
    try {
      final rep = ref.watch(commentRepositoryProvider);
      final count = await rep.getCommentsCount(routeId: widget.routeId);
      if (mounted) {
        setState(() {
          commentsCount = count;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getUserRoutesCount() async {
    try {
      final rep = ref.watch(routeRepositoryProvider);
      final count = await rep.getUserRoutesCount(
        creatorId: widget.route.creatorId,
      );
      setState(() {
        userRoutesCount = count;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getAverageUserRoutesRating() async {
    try {
      final rep = ref.watch(routeRepositoryProvider);
      final averageRating = await rep.getAverageUserRoutesRating(
        userId: widget.route.creatorId,
      );
      setState(() {
        averageUserRoutesRating = averageRating;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getAverageRating() async {
    try {
      final rep = ref.watch(commentRepositoryProvider);
      final rating = await rep.getAverageRating(routeId: widget.routeId);
      if (mounted) {
        setState(() {
          averageRating = rating;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getComments() async {
    try {
      final result = await ref
          .read(commentRepositoryProvider)
          .getComments(routeId: widget.route.id);
      if (mounted) {
        setState(() {
          commentsList = result;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getComments();
      getCommentsCount();
      getAverageRating();
      getUserRoutesCount();
      getAverageUserRoutesRating();
    });
    super.initState();

    myItems = widget.route.photoUrls
        .map(
          (url) => SizedBox(
            width: double.infinity,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[50],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[50],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ошибка загрузки изображения',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RouteDescriptionContent(
        creator: widget.route.creator!,
        route: widget.route,
        myItems: myItems,
        currentIndex: currentIndex,
        commentsCount: commentsCount,
        averageRating: averageRating,
        userRoutesCount: userRoutesCount,
        averageUserRoutesRating: averageUserRoutesRating,
        commentsList: commentsList,
        onReviewPressed: showBottomSheet,
      ),
    );
  }
}
