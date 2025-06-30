import 'package:flutter/material.dart';

class RouteDescriptionWidget extends StatelessWidget {
  const RouteDescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Описание маршрута',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 7,
            ),
            Text(
              'Uhjrwhe htjkrwnmrwegh ruiewirjlwejrlw jelrjhlwejhrlwk elklf kjldjklgfhjk lsdhlghjks dlhufg husdh fuglh ksdf jhklgjhk sdfghj klsdkh jg hjkl',
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
