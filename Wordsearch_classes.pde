
class Grid {
  int numRows, numColumns;
  int tileSize, gridWidth, gridHeight;
  Cell[][] cells;

  Grid(int numRows, int numColumns, int tileSize) {
    this.numRows = numRows;
    this.numColumns = numColumns;
    this.tileSize = tileSize;

    gridWidth  = tileSize * numColumns;
    gridHeight = tileSize * numRows;
  }

  void display() {
    drawGrid();
    drawIndexes();

    for (Cell[] rows : cells) {
      for (Cell cell : rows) {
        cell.display();
      }
    }
  }

  void drawGrid() {
    for (int y = 0; y <= gridHeight; y += tileSize) {
      for (int x = 0; x <= gridWidth; x += tileSize) {
        line(x, 0, x, gridHeight);
        line(0, y, gridWidth, y);
      }
    }
  }

  void drawIndexes() {
    textSize(10);
    fill(0);
    for (int row = 0; row < numRows; row++) text(row, -10, row * tileSize + tileSize/2);
    for (int col = 0; col < numColumns; col++) text(col, col * tileSize + tileSize/2, -10);
  }

  void populateGrid(Cell[][] cells) {
    this.cells = cells;
  }

  ID getCellID(float x, float y) {
    for (Cell[] rows : cells) {
      for (Cell cell : rows) {
        if (cell.box.contains(x, y)) return cell.getID();
      }
    }
    return null;
  }

  Cell getCell(ID id) {
    for (Cell[] rows : cells) {
      for (Cell cell : rows) {
        if (cell.id == id) return cell;
      }
    }
    return null;
  }
}

class Cell {
  char letter;
  ID id;
  int cellSize;
  boolean isChecked;
  boolean isBlank = true;
  boolean isFirst = false;
  boolean isLast = false;
  boolean isLocked = false;
  Rectangle box;

  final int defaultState = 220;
  final int selectedState = color(0, 80);
  final int lockedState = #00FF00;
  color cellColor = color(255, 0);//defaultState;

  Cell(char ch, ID id, int cellSize) {
    this.letter = ch;
    this.id = id;
    this.cellSize = cellSize;
    box = new Rectangle(applet, cellSize);
  }

  Cell getCell() {
    return this;
  }

  void display() {
    push();
    translate(id.col * cellSize, id.row * cellSize);
    noFill();
    noStroke();
    box.get();
    //fill(box.contains(mouseX, mouseY) ? selectedState : defaultState);
    //if (isBlank) noFill();
    //else fill(cellColor);
    //fill(cellColor);
    //if (isChecked) fill(#00FF00);
    //else fill(box.contains(leftHand.pos) ? #00FF00 : box.contains(rightHand.pos) ? #00FF00 : cellColor);

    if (isLocked) fill(lockedState);
    else noFill();

    square(0, 0, cellSize);

    textSize(cellSize);
    textAlign(LEFT, TOP);
    fill(textColor);
    text(letter, cellSize*0.2, -cellSize*0.2);
    pop();
  }
  color textColor = 0;
  ID getID() {
    return id.get();
  }
}

class KeyWord {
  ID first, last;
  ArrayList<Cell> cells = new ArrayList();
  ArrayList<ID> cellsID = new ArrayList();
  PVector dir = new PVector();
  String word;
  boolean isValidated;

  void setFirst(ID first) {
    this.first = first;
  }

  void setLast(ID last) {
    this.last = last;
  }

  void addCell(Cell cell) { 
    cells.add(cell);
  }

  Cell[] getCells() {
    Cell[] result = new Cell[cells.size()];
    return cells.toArray(result);
  }

  void changeColor() {
    if (isValidated) for (Cell c : cells) c.isChecked = true;
  }

  void setOrientation(PVector dir) {
    this.dir = dir;
  }

  void setWord(String word) {
    this.word = word;
  }

  String getWord() {
    return this.word;
  }

  String toString() {
    return word + " | first: "+first + " | last: " + last;
  }
}

class ID {
  int row, col;

  ID(int row, int col) {
    this.row = row;
    this.col = col;
  }

  ID get() {
    return this;
  }

  String toString() {
    return "row: " + row + ", col: " + col;
  }

  public int hashCode() {
    int hash = 7;
    hash = 13 * hash + this.row;
    hash = 13 * hash + this.col;
    return hash;
  }

  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }
    if (obj == null) {
      return false;
    }
    if (getClass() != obj.getClass()) {
      return false;
    }
    final ID other = (ID) obj;
    if (this.row != other.row) {
      return false;
    }
    if (this.col != other.col) {
      return false;
    }
    return true;
  }
}

ID setID(int row, int col) {
  return new ID(row, col);
}
