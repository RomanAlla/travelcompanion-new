import 'package:flutter/material.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';

class RouteCreatorInfoWidget extends StatelessWidget {
  final String creatorName;
  final RouteModel route;
  final double averageUserRoutesRating;
  final int userRoutesCount;
  const RouteCreatorInfoWidget({
    super.key,
    required this.creatorName,
    required this.route,
    required this.averageUserRoutesRating,
    required this.userRoutesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: route.creator!.avatarUrl != null
                  ? NetworkImage(route.creator!.avatarUrl!)
                  : null,
              child: route.creator!.avatarUrl == null
                  ? CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, color: Colors.blue[700]),
                    )
                  : null,
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text('Автор маршрута', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 3),
                    Text(
                      '$averageUserRoutesRating',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '$userRoutesCount',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 60),
            Icon(Icons.verified),
          ],
        ),
      ),
    );
  }
}
