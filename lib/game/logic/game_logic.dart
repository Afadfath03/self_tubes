import 'dart:math';
import '../models/tile.dart';

class GameLogic {
  static const int gridSize = 4;

  late List<List<Tile>> grid;
  late bool gameOver;
  int score = 0;

  GameLogic() {
    resetGame();
  }

  void resetGame() {
    grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => Tile()),
    );
    score = 0;
    addRandomTile();
    addRandomTile();
    gameOver = false;
  }

  void addRandomTile() {
    List<Point<int>> emptyTiles = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].value == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }
    if (emptyTiles.isNotEmpty) {
      final random = Random();
      Point<int> selected = emptyTiles[random.nextInt(emptyTiles.length)];
      grid[selected.x][selected.y].value = Random().nextInt(10) < 9 ? 2 : 4;
    }
  }

  bool canMove() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].value == 0) return true;
        if (i < gridSize - 1 && grid[i][j].value == grid[i + 1][j].value) {
          return true;
        }
        if (j < gridSize - 1 && grid[i][j].value == grid[i][j + 1].value) {
          return true;
        }
      }
    }
    return false;
  }

  void resetMerged() {
    for (var row in grid) {
      for (var tile in row) {
        tile.resetMerge();
      }
    }
  }

  bool moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<Tile> row = grid[i]
          .where((tile) => tile.value != 0)
          .map((tile) => tile.copy())
          .toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j].value == row[j + 1].value &&
            !row[j].merged &&
            !row[j + 1].merged) {
          row[j].value *= 2;
          row[j].merged = true;
          score += row[j].value;
          row[j + 1].value = 0;
          moved = true;
        }
      }
      row = row.where((tile) => tile.value != 0).toList();
      while (row.length < gridSize) {
        row.add(Tile());
      }
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].value != row[j].value) {
          moved = true;
          grid[i][j].value = row[j].value;
          grid[i][j].merged = row[j].merged;
        }
      }
    }
    return moved;
  }

  bool moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<Tile> row = grid[i]
          .where((tile) => tile.value != 0)
          .map((tile) => tile.copy())
          .toList()
          .reversed
          .toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j].value == row[j + 1].value &&
            !row[j].merged &&
            !row[j + 1].merged) {
          row[j].value *= 2;
          row[j].merged = true;
          score += row[j].value;
          row[j + 1].value = 0;
          moved = true;
        }
      }
      row = row.where((tile) => tile.value != 0).toList();
      while (row.length < gridSize) {
        row.add(Tile());
      }
      row = row.reversed.toList();
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].value != row[j].value) {
          moved = true;
          grid[i][j].value = row[j].value;
          grid[i][j].merged = row[j].merged;
        }
      }
    }
    return moved;
  }

  bool moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<Tile> column = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j].value != 0) column.add(grid[i][j].copy());
      }
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i].value == column[i + 1].value &&
            !column[i].merged &&
            !column[i + 1].merged) {
          column[i].value *= 2;
          column[i].merged = true;
          score += column[i].value;
          column[i + 1].value = 0;
          moved = true;
        }
      }
      column = column.where((tile) => tile.value != 0).toList();
      while (column.length < gridSize) {
        column.add(Tile());
      }
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j].value != column[i].value) {
          moved = true;
          grid[i][j].value = column[i].value;
          grid[i][j].merged = column[i].merged;
        }
      }
    }
    return moved;
  }

  bool moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<Tile> column = [];
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j].value != 0) column.add(grid[i][j].copy());
      }
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i].value == column[i + 1].value &&
            !column[i].merged &&
            !column[i + 1].merged) {
          column[i].value *= 2;
          column[i].merged = true;
          score += column[i].value;
          column[i + 1].value = 0;
          moved = true;
        }
      }
      column = column.where((tile) => tile.value != 0).toList();
      while (column.length < gridSize) {
        column.add(Tile());
      }
      column = column.reversed.toList();
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j].value != column[i].value) {
          moved = true;
          grid[i][j].value = column[i].value;
          grid[i][j].merged = column[i].merged;
        }
      }
    }
    return moved;
  }

  bool swipe(String direction) {
    resetMerged();
    bool moved = false;
    switch (direction) {
      case 'up':
        moved = moveUp();
        break;
      case 'down':
        moved = moveDown();
        break;
      case 'left':
        moved = moveLeft();
        break;
      case 'right':
        moved = moveRight();
        break;
    }
    if (moved) {
      addRandomTile();
      if (!canMove()) {
        gameOver = true;
      }
    }
    return moved;
  }
}
