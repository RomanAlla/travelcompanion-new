import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class HelperWidget extends StatefulWidget {
  String text;
  HelperWidget({super.key, required this.text});

  @override
  State<HelperWidget> createState() => _HelperWidgetState();
}

class _HelperWidgetState extends State<HelperWidget> {
  bool showInstraction = true;
  double _instructionOffset = -0.2;
  double _instructionOpacity = 0.0;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _instructionOffset = 0.0;
        _instructionOpacity = 1.0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showInstraction = false;
                        });
                      },
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
