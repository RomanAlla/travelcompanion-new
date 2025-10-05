import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/data/services/map_state_notifier.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/widgets/helper_widget.dart';
import 'package:travelcompanion/features/map/presentation/widgets/quit_button_widget.dart';
import 'package:travelcompanion/features/map/presentation/widgets/yandex_map_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';

@RoutePage()
class MapScreen extends ConsumerStatefulWidget {
  final MapMode mode;
  const MapScreen({super.key, this.mode = MapMode.viewAll});

  @override
  ConsumerState<MapScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final bool _showInstruction = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(() {
        if (_sheetController.size <= 0.3) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _sheetController.dispose();

    super.dispose();
  }

  void _handleQuit() {
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    notifier.clearTappedPoint();
    notifier.clearPastPolilynes();
    context.router.pop();
  }

  void _handleClearTappedPoint() {
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    notifier.clearTappedPoint();
    notifier.clearPastPolilynes();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStateNotifierProvider);
    return Scaffold(
      body: Stack(
        children: [
          YandexMapWidget(mode: widget.mode),
          if (_showInstruction)
            HelperWidget(
              text: 'Нажмите на метку, чтобы увидеть полный маршрут',
            ),

          state.hasTappedPoint
              ? SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BackActionButtonWidget(
                          onPressed: _handleClearTappedPoint,
                          label: 'Вернуться',
                        ),
                        SizedBox(width: 30),
                        ContinueActionButtonWidget(
                          onPressed: () {},
                          label: 'Продолжить',
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,

                      child: QuitButtonWidget(onPressed: _handleQuit),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
