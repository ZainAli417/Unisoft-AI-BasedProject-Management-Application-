import 'package:flutter/material.dart';

class DashboardAddButton extends StatelessWidget {
  final VoidCallback? iconTapped;
  const DashboardAddButton({
    Key? key,
    this.iconTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: iconTapped,
      child: Container(
          width: 55,
          height: 55,
          decoration: const BoxDecoration(
              color: Colors.cyan, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}
