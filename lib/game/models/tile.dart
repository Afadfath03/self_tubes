class Tile {
  int value;
  bool merged;

  Tile({this.value = 0, this.merged = false});

  void resetMerge() {
    merged = false;
  }

  Tile copy() {
    return Tile(value: value, merged: merged);
  }
}
