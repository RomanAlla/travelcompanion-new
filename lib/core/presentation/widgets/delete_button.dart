import 'package:flutter/material.dart';

class DeleteButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  const DeleteButtonWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStatePropertyAll(Size.zero),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: WidgetStatePropertyAll(0),
      ),
      onPressed: onPressed,
      color: Colors.red,
      icon: Icon(Icons.delete, color: Colors.red),
    );
  }
}
