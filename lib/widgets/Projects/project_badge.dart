import 'package:flutter/material.dart';


class ColouredProjectBadge extends StatelessWidget {
  const ColouredProjectBadge({
    Key? key,
    required this.projeImagePath,
  }) : super(key: key);
  final String projeImagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.network(projeImagePath));
  }
}
