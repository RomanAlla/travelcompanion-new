import 'package:flutter/material.dart';

class ModalPointSelectContainerWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

  const ModalPointSelectContainerWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<ModalPointSelectContainerWidget> createState() =>
      _ModalPointSelectContainerWidgetState();
}

class _ModalPointSelectContainerWidgetState
    extends State<ModalPointSelectContainerWidget> {
  void _showFullAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(widget.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Полный адрес')),
          ],
        ),
        content: SelectableText(
          widget.title,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLongText = widget.title.length > 25;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isActive
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isActive
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.2),
            width: widget.isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive
                  ? theme.colorScheme.primary
                    : Colors.grey[600],
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: isLongText ? _showFullAddressDialog : null,
              child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isActive
                            ? theme.colorScheme.primary
                            : Colors.black87,
                ),
                      maxLines: 2,
                overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isActive) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
