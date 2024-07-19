import 'package:flutter/material.dart';
import '../../Values/values.dart';

class ColouredCategoryBadge extends StatelessWidget {
  const ColouredCategoryBadge({
    Key? key,
    required this.color,
    required this.icon,
  }) : super(key: key);

  final Icon icon;
  final String color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // color: HexColor.fromHex(color),
        gradient: RadialGradient(
          radius: 0,
          colors: [
            HexColor.fromHex(color).withOpacity(1),
            Colors.black,
            HexColor.fromHex(color).withOpacity(1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 254, 254).withOpacity(0.6),
            blurRadius: 5,
            offset: const Offset(4, 3),
          ),
        ],
      ),
      child: icon,
    );
  }
}
