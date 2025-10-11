import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/favourite_repository_provider.dart';

class CarouselSliderWidget extends ConsumerStatefulWidget {
  final List<Widget> items;
  final int count;

  final RouteModel route;
  final WidgetRef ref;
  const CarouselSliderWidget({
    super.key,
    required this.items,
    required this.count,

    required this.route,
    required this.ref,
  });

  @override
  ConsumerState<CarouselSliderWidget> createState() =>
      _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  int activeIndex = 0;

  Future<void> addToFavouriteRoute() async {
    try {
      final user = widget.ref.read(userNotifierProvider).user;
      if (user == null) return;

      final addToFavouritesUseCase = widget.ref.read(
        addToFavouritesUseCaseProvider,
      );

      await addToFavouritesUseCase(routeId: widget.route.id, userId: user.id);
      widget.ref.invalidate(favouriteListProvider);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          items: widget.items,
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
            height: 300,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayInterval: Duration(seconds: 3),
            autoPlay: false,
          ),
        ),
        if (widget.items.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                effect: WormEffect(
                  type: WormType.thinUnderground,
                  spacing: 3,
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: Colors.white,
                  dotColor: const Color.fromARGB(255, 206, 206, 206),
                ),
                activeIndex: activeIndex,
                count: widget.items.length,
              ),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    border: null,
                    color: AppTheme.primaryLightColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.router.pop(context),
                  ),
                ),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    border: null,
                    color: AppTheme.primaryLightColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: addToFavouriteRoute,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
