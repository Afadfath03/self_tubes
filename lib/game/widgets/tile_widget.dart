import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  Color getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey[200]!;
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.grey[400]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.orange[500]!;
      case 64:
        return Colors.orange[600]!;
      case 128:
        return Colors.red[300]!;
      case 256:
        return Colors.red[400]!;
      case 512:
        return Colors.red[500]!;
      case 1024:
        return Colors.red[600]!;
      case 2048:
        return Colors.purple[600]!;
      case 4096:
        return Colors.purple[700]!;
      case 8192:
        return Colors.purple[800]!;
      case 16384:
        return Colors.purple[900]!;
      default:
        return Colors.black;
    }
  }

  Color getTextColor(int value) {
    return value < 8 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getTileColor(value),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          value != 0 ? value.toString() : '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: getTextColor(value),
          ),
        ),
      ),
    );
  }
}
