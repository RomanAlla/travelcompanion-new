import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class HelperWidget extends StatefulWidget {
  final String text;
  const HelperWidget({super.key, required this.text});

  @override
  State<HelperWidget> createState() => _HelperWidgetState();
}

class _HelperWidgetState extends State<HelperWidget> {
  bool _showInstraction = true;
  double _instructionOffset = -0.2;
  double _instructionOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
      setState(() {
        _instructionOffset = 0.0;
        _instructionOpacity = 1.0;
      });
      }
    });
  }

  void _closeInstruction() {
    if (mounted) {
    setState(() {
      _showInstraction = false;
      _instructionOffset = -0.2;
      _instructionOpacity = 0.0;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showInstraction) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: AnimatedSlide(
        offset: Offset(0, _instructionOffset),
        duration: Duration(milliseconds: 600),
        child: AnimatedOpacity(
          opacity: _instructionOpacity,
          duration: Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Показываем индикатор загрузки для текста "Построение маршрута..."
                    if (widget.text.contains('Построение маршрута'))
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLightColor,
                          ),
                        ),
                      )
                    else
                    Icon(
                      Icons.touch_app,
                      color: AppTheme.primaryLightColor,
                      size: 22,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ),
                    // Скрываем кнопку закрытия во время загрузки
                    if (!widget.text.contains('Построение маршрута'))
                    GestureDetector(
                        onTap: _closeInstruction,
                      child: Icon(Icons.close, size: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
