
class MenuMode {
  int currentMenu = 0;
  ArrayList<Menu> menus = new ArrayList();
  Movie bgVideo, tuto1;
  PImage logo;

  MenuMode() {
    menus.add(new Menu_tutorial("TUTORIAL"));
    menus.add(new Menu_main("MAIN MENU"));
    menus.add(new Playground("PLAYGROUND"));

    logo = loadImage("logo.png");

    bgVideo = new Movie(applet, "Terrain_3D_v4_TEXT.mp4");
    bgVideo.loop();

    tuto1 = new Movie(applet, "tutorial2.mov");
    tuto1.loop();
    currentMenu = 0;
  }

  void run() {    
    if (currentMenu != 2) {
      if (currentMenu == 0) {
        tint(255, 100);
        image(tuto1, 0, 0, width, height);
      } else {
        imageMode(CORNER);
        tint(255, 50);
        image(bgVideo, 0, 0, width, height);

        imageMode(CENTER);
        tint(255);
        image(logo, width/2, height/5);
        imageMode(CORNER);
      }
    }

    switch(currentMenu) {
    case 0:
      menus.get(currentMenu).run();
      if (menus.get(0).isFinished()) {
        menus.get(0).reset();
        currentMenu = 1;
      }
      break;
    case 1:
      menus.get(1).run();
      if (menus.get(1).toPlayroom) {
        menus.get(1).reset();
        bgVideo.stop();
        currentMenu = 2; // GOES TO PLAYROOM
      } else if (menus.get(1).isFinished()) {
        menus.get(1).reset();
        currentMenu = 0;
        gameState = GameState.GAME_MODE; // CHANGE TO GAME STATE
      }
      break;
    case 2: // PLAYROOM
      menus.get(2).run();
      if (menus.get(2).isFinished()) {
        menus.get(2).reset();
        bgVideo.loop();
        currentMenu = 0;
      }
      break;
    }
  }
}

abstract class Menu implements StateOutput {
  String name;
  boolean isFinished, toPlayroom;

  Menu(String name) {
    this.name = name;
  }

  abstract void run();
  abstract void clickButton(PVector p);
  abstract void addForce(Particle hand, int power);
  abstract void removeForce();
  abstract void resetLetters();

  boolean isFinished() {
    return isFinished;
  }

  void reset() {
    isFinished = false;
  }
}

class Menu_tutorial extends Menu {
  Button endTutorial;

  Menu_tutorial(String name) {
    super(name);
    endTutorial = new Button("ok2.png", width/2, 3*height/5, 300, 100);
  }

  void run() {
    push();
    textSize(35);
    fill(0);
    text(name, width/10, height/10);
    endTutorial.display();
    pop();
  }

  void clickButton(PVector p) {
    if (endTutorial.contains(p)) isFinished = true;
  }
  void addForce(Particle hand, int power) {
  }
  void removeForce() {
  }
  void resetLetters() {
  }
}

class Menu_main extends Menu {
  Button playRoom, campaign;
  PImage btnDisabled;

  Menu_main(String name) {
    super(name);
    campaign = new Button("campaign1.png", width/2, height/2 - 100, 500, 120);
    playRoom = new Button("playroom1.png", width/2, height/2 + 100, 500, 120);

    btnDisabled = loadImage("playroom3.png");
    btnDisabled.resize(500, 120);
  }

  void run() {
    push();
    textSize(35);
    fill(0);
    text(name, width/10, height/10);
    campaign.display();

    if (playroomIndex > 1) playRoom.display();
    else image(btnDisabled, width/2-btnDisabled.width/2, height/2 + 100 + btnDisabled.height/2);
    pop();
  }

  void clickButton(PVector p) {
    if (playRoom.contains(p)) toPlayroom = true;
    else if (campaign.contains(p)) isFinished = true;
  }

  void reset() {
    isFinished = false;
    toPlayroom = false;
  }
  void addForce(Particle hand, int power) {
  }
  void removeForce() {
  }
  void resetLetters() {
  }
}

class Playground extends Menu {
  Button backToMenu;
  ArrayList<Letter> letters;

  Playground(String name) {
    super(name);
    backToMenu = new Button("menu2.png", width/2, 3*height/5, 300, 100);

    String[] txt = loadStrings("Os Lusiadas.txt");

    int size = 25;
    int x = size/2, y = size;
    textFont(createFont("Space Mono", size));
    textAlign(CENTER);

    letters = new ArrayList();
    for (int i = 0; i < txt.length; i++) {
      for (int j = 0; j < txt[i].length(); j++) {

        char c = txt[i].charAt(j);
        letters.add(new Letter(c, x, y));

        x += textWidth(c);
        if (x >= width) {
          x = size/2;
          y += size;
        }
        if (y > height) break;
      }
    }
    //println(letters.size());
  }


  void run() {
    push();
    fill(0);
    for (Letter l : letters) {
      l.display();
      l.update();
    }
    backToMenu.display();
    pop();
  }

  void reset() {
    menuMode.menus.add(2, new Playground("PLAYGROUND"));
  }

  void clickButton(PVector p) {
    if (backToMenu.contains(p)) isFinished = true;
  }

  void addForce(Particle hand, int val) {
    for (Letter l : letters) 
      physics.makeAttraction(hand, l.particle, val, 35);
  }

  void resetLetters() {
    for (Letter m : letters) m.resetPosition = !m.resetPosition;
  }

  void removeForce() {
    for (int i = 0; i < physics.numberOfAttractions(); i++) {
      Attraction t = physics.getAttraction(i);
      t.setStrength(-200);
    }
    for ( int i = 0; i < physics.numberOfAttractions(); i++) {
      physics.removeAttraction(i);
    }
  }

  class Letter {
    char ch;
    Particle particle;
    PVector originalPos;

    float speedRatio = 20.0f;
    boolean resetPosition;

    Letter(char ch, float x, float y) {
      this.ch = ch;
      particle = physics.makeParticle(1, x, y, 0);
      originalPos = new PVector(x, y);
    }

    void display() {
      text(ch, particle.position().x(), particle.position().y());
    }

    void update() {
      PVector currentPos = new PVector(particle.position().x(), particle.position().y());

      if (resetPosition && !currentPos.equals(originalPos)) {
        PVector vel = PVector.sub(originalPos, currentPos).div(speedRatio);
        particle.position().add(vel.x, vel.y, 0);

        if (PVector.dist(currentPos, originalPos) < 1) {
          particle.position().setX(originalPos.x);
          particle.position().setY(originalPos.y);
        }
      }
    }
  }
}
