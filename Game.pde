


public class GameMode {
  ArrayList<Level> gameLevels = new ArrayList();
  int currentLevel = 0;

  GameMode() {
    String[] words = {"nuclear", "missiles", "president", "bomb"};
    gameLevels.add(new WordSearch("WORD SEARCH", words));
  }

  void run() {
    switch(currentLevel) {
    case 0:
      gameLevels.get(0).run();

      break;
    }
  }

  /*
  void showList() {
   for (int i = 0; i < gameLevels.get(0).keyWords.length; i++) {
   if (gameLevels.get(0).keyWords[i].isValidated == true) fill(0, 255, 0);
   else fill(0);
   textSize(20);
   text(gameLevels.get(0).keyWords[i].word, width - 200, 50 + (20 * i));
   }
   } */
}


abstract class Level {
  int levelIndex;
  String title;
  KeyWord[] keyWords;
  PVector mp = new PVector();
  Movie tuto3, msg1, medal, msg4;
  boolean intro = true;

  Level(String title) {
    this.title = title;
  }

  abstract void run();
  abstract void startSelection(float x, float y);
  abstract void validateSelection(float x, float y);
  abstract boolean endGame();
}
