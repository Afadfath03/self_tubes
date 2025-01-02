import 'package:flutter/material.dart';
import '../logic/game_logic.dart';
import 'tile_widget.dart';

class GameGrid extends StatelessWidget {
  final GameLogic gameLogic;

  const GameGrid({super.key, required this.gameLogic});

  @override
  Widget build(BuildContext context) {
    double gridSizePx = MediaQuery.of(context).size.width - 40;

    return Container(
      width: gridSizePx,
      height: gridSizePx,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GridView.builder(
        itemCount: GameLogic.gridSize * GameLogic.gridSize,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GameLogic.gridSize,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          int row = index ~/ GameLogic.gridSize;
          int col = index % GameLogic.gridSize;
          int value = gameLogic.grid[row][col].value;
          return TileWidget(value: value);
        },
      ),
    );
  }
}
