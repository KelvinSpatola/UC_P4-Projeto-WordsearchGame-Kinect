
class WordSearch extends Level {
  final char[] charTable = new char[]{
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' 
  };

  Grid grid;
  //String[] keyWords;
  KeyWord[] keyWords;
  ID start, end;
  int rowChosen, colChosen;
  boolean gameIsFinished;
  int countValidated = 0;
  int xoff, yoff;


  // CONSTRUCTOR
  WordSearch(String title, String ... words) {
    super(title);
    keyWords = new KeyWord[words.length];
    grid = new Grid(10, 15, 75);

    Cell[][] cells = new Cell[grid.numRows][grid.numColumns];
    for (int i = 0; i < grid.numRows; i++) {
      for (int j = 0; j < grid.numColumns; j++) {
        cells[i][j] = new Cell(charTable[(int)random(charTable.length)], setID(i, j), grid.tileSize);
      }
    }
    grid.populateGrid(cells);
    placeKeyWords(words);
    getKeyWordsIDs();

    xoff = width/2 - grid.gridWidth/2;
    yoff = height/2 - grid.gridHeight/2;

    msg1 = new Movie(applet, "message1.mov");
    tuto3 = new Movie(applet, "tutorial3.mov");
    medal = new Movie(applet, "medal.mov");
    msg4 = new Movie(applet, "message4.mov");
  }

  // ***************** DISPLAY ***************** //
  void run() {
    if (intro) {
      if (msg1.time() < msg1.duration()) {
        msg1.play();
        tint(255);
        image(msg1, 0, 0, width, height);
      } else {
        tuto3.play();
        tint(255);
        image(tuto3, 0, 0, width, height);
      }
      if (tuto3.time() == tuto3.duration()) {
        intro = false;
      }
    } else {

      if (endGame()) {

        if (msg4.time() < msg4.duration()) {
          msg4.play();
          tint(255);
          image(msg4, 0, 0, width, height);
        } else {
          medal.play();
          tint(255);
          image(medal, 0, 0, width, height);
        }

        if (medal.time() == medal.duration()) {
          setup();
        }
      } else {

        push();
        textSize(35);
        fill(0);
        text(title, width/10, height/10);
        pop();

        push();
        translate(xoff, yoff);
        grid.display();
        pop();

        displayWords();
        drawMarkers();
      }
    }
  }

  void drawMarkers() {
    push();
    strokeCap(PROJECT);
    strokeWeight(50);
    stroke(0, 0, 255, 100);

    if (leftHand.close.isActive()) 
      line(mp.x, mp.y, leftHand.pos.x, leftHand.pos.y);

    if (rightHand.close.isActive()) 
      line(mp.x, mp.y, rightHand.pos.x, rightHand.pos.y);

    pop();
  }

  void displayWords() {
    push();
    //fill(0);
    textSize(30);
    textAlign(LEFT);
    float x = width - 200;
    translate(x, yoff + 50);
    for (int i = 0; i < keyWords.length; i++) {
      if (keyWords[i].isValidated == true) {
        for (Cell c : keyWords[i].getCells()) c.textColor = #00FF00;
        fill(0, 255, 0);
      } else fill(0);
      text(keyWords[i].getWord(), 0, i * 50);
    }
    pop();
  }

  void placeKeyWords(String ... words) {
    words = sortByLengthInverse(words);

    for (int k = 0; k < words.length; k++) {

      pickRandomCell();
      keyWords[k] = new KeyWord();
      keyWords[k].setFirst(new ID(rowChosen, colChosen));
      PVector dir = pickRandomDirection(words[k]);

      keyWords[k].setOrientation(dir);

      int index = 0;
      while (index < words[k].length()) {
        grid.cells[rowChosen][colChosen].letter = words[k].toUpperCase().charAt(index);
        grid.cells[rowChosen][colChosen].isBlank = false;
        keyWords[k].cellsID.add(grid.cells[rowChosen][colChosen].getID());
        //keyWords[k].addCell(grid.cells[rowChosen][colChosen]);
        //grid.cells[rowChosen][colChosen].cellColor = #FF0000;

        if (index == 0) { 
          grid.cells[rowChosen][colChosen].isFirst = true;
          keyWords[k].setFirst(new ID(rowChosen, colChosen));
        }
        if (index == words[k].length()-1) {
          grid.cells[rowChosen][colChosen].isLast = true;
          keyWords[k].setLast(new ID(rowChosen, colChosen));
        }

        rowChosen += dir.y;
        colChosen += dir.x;
        index++;
      }
      keyWords[k].setWord(words[k]);
      //println("RESULT DIR: " + chosenDir);
    }
  }

  void getKeyWordsIDs() {
    for (int i = 0; i < keyWords.length; i++) println(keyWords[i]);
  }

  void pickRandomCell() {
    rowChosen = floor(random(grid.numRows));
    colChosen = floor(random(grid.numColumns));
  }

  void startSelection(float x, float y) {
    ID id = grid.getCellID(x, y);
    if (id == null) return;
    //println("START: "+id);

    start = id;
    Cell cell = grid.getCell(id);
    cell.cellColor = cell.selectedState;
  }

  void validateSelection(float x, float y) {
    ID id = grid.getCellID(x, y);
    end = id;
    if (id == null || start == null || start == end) return;

    Cell cellCliked = grid.getCell(start);
    Cell cellReleased  = grid.getCell(end);

    if ((cellCliked.isFirst || cellCliked.isLast) && (cellReleased.isFirst || cellReleased.isLast)) {
      String result = "";
      // LETS PICK UP THE WORD, FINALLY...
      for (int i = 0; i < keyWords.length; i++) {
        KeyWord key = keyWords[i];
        //grid.isValidated();
        if ((key.first.equals(start) || key.first.equals(end)) && (key.last.equals(start) || key.last.equals(end))) {
          if (keyWords[i].isValidated == false) {

            for (int j = 0; j < keyWords[i].cellsID.size(); j++)
              grid.getCell(keyWords[i].cellsID.get(j)).isLocked = true;

            result = keyWords[i].getWord();
            keyWords[i].isValidated = true;
            keyWords[i].changeColor();
            countValidated++;
            println(result, countValidated);
          }
        }
      }
      //println(result);
    } else println("NO WORD");
  }

  PVector chosenDir = new PVector();

  PVector pickRandomDirection(String word) {
    //println(word);
    PVector result = new PVector();
    boolean validPlace = false;
    int count = 0;
    int maxIterations = 50;

    do {
      //println("trying: "+word+", iteration: "+count);
      float orientation = random(0, 1f);

      if (orientation > 0.5) { // horizontal
        if (colChosen + word.length() > grid.numColumns && colChosen - word.length() < 0) validPlace = false;
        else if (colChosen + word.length() > grid.numColumns) { // left
          result.set(-1, 0);
          validPlace = true;
        } else { // right
          result.set(1, 0);
          validPlace = true;
        }
        //validPlace = true;
      } else { // vertical
        if (rowChosen + word.length() > grid.numRows && rowChosen - word.length() < 0) validPlace = false;
        else if (rowChosen + word.length() > grid.numRows) { // up
          result.set(0, -1);
          validPlace = true;
        } else { // down
          result.set(0, 1); 
          validPlace = true;
        }
        //validPlace = true;
      }

      if (noOverlapping(word.length(), result) == false) {
        validPlace = false;
        pickRandomCell();
        count = 0;
      }

      if (count > maxIterations) {
        validPlace = false;
        pickRandomCell();
        count = 0;
        //println("CHANGED VALUES");
      }

      count++;
    } while (validPlace == false);

    chosenDir = result;
    return result;
  }

  boolean noOverlapping(int size, PVector dir) {
    int row = rowChosen;
    int col = colChosen;
    //println(size);
    for (int i = 0; i < size; i++) {
      if (grid.cells[row][col].isBlank == false) {
        // println(grid.cells[row][col].id);
        return false;
      }
      row += dir.y;
      col += dir.x;
    }
    return true;
  }


  String[] sortByLength(String[] lines) {
    int[] sizes = new int[lines.length];
    for (int i = 0; i < sizes.length; i++) sizes[i] = lines[i].length();
    sizes = sort(sizes);

    String[] result = new String[lines.length];
    for (int i = 0; i < lines.length; i++) {
      for (int j = 0; j < sizes.length; j++) {
        if (lines[i].length() == sizes[j]) result[j] = lines[i];
      }
    }
    return result;
  }

  String[] sortByLengthInverse(String[] lines) {
    return reverse(sortByLength(lines));
  }

  public boolean endGame() {
    if (countValidated >= keyWords.length)  gameIsFinished = true;
    else gameIsFinished = false;
    return gameIsFinished;
  }
}
