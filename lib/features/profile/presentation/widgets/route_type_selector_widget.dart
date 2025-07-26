// import 'package:flutter/material.dart';

// class RouteTypeSelectorWidget extends StatefulWidget {
//   final List<String> routeTypes;
//   const RouteTypeSelectorWidget({
//     super.key,
//     required this.routeType,
//     required this.routeTypes,
//   });

//   @override
//   State<RouteTypeSelectorWidget> createState() =>
//       _RouteTypeSelectorWidgetState();
// }

// class _RouteTypeSelectorWidgetState extends State<RouteTypeSelectorWidget> {
//   String? routeType;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Категория маршрута',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: widget.routeType,
//                 isExpanded: true,
//                 hint: const Text('Выберите категорию'),
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   color: Color(0xFF6C5CE7),
//                 ),
//                 items: widget.routeTypes.map((type) {
//                   return DropdownMenuItem(
//                     value: type,
//                     child: Row(
//                       children: [
//                         Icon(
//                           _getIconForRouteType(type),
//                           color: const Color(0xFF6C5CE7),
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(type),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => routeType = value),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
