/* *************************************************** /
 *                      PROJETO 4                      *
 *         *** INTERAÇÃO COM CAMERA KINECT ***         *
 *                      2019/2020                      *
 * --------------------------------------------------- *
 *                     autores:                        *
 *          Aretm Basok     - 2017258438               *
 *          Kelvin Spátola  - 2017230108               *
 *          Pedro Tavares   - 2017269091               *
 *          Ricardo Marques - 2017256741               *
 * *************************************************** */


import kelvinclark.utils.Trigger;
import kelvinclark.utils.Rectangle;
import processing.video.*;
import com.hamoid.*;
import traer.physics.*;
import KinectPV2.*;
import gab.opencv.*;

//  ********** ALL GLOBAL VARIABLES ********** //
PApplet applet;
VideoExport videoExport;
KinectPV2 kinect;
OpenCV opencv;

Body body;
Hand leftHand, rightHand;
ParticleSystem physics;

MenuMode menuMode;
GameMode gameMode;

enum GameState {
  MAIN_MENU, GAME_MODE
}
GameState gameState;
int playroomIndex = 0;

void setup() {
  fullScreen();
  playroomIndex++;
  textFont(createFont("Space Mono", 100));

  applet = this;

  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true); // para obter os pontos do esqueleto
  kinect.enableDepthImg(true); // para obter imagem de profundidade. Necessário para obter o contorno do corpo humano
  kinect.enablePointCloud(true); // para obter imagem do infrared. Necessário para obter o contorno do corpo humano
  kinect.enableColorImg(true); // para obter imagem RGB normal da camera
  kinect.init();

  body = new Body(this);

  leftHand = new Hand("left");
  rightHand = new Hand("right");

  gameState = GameState.MAIN_MENU;

  menuMode = new MenuMode();
  gameMode = new GameMode();

  //setupVideoExport("output.mp4", 20, 50);
}

void draw() {
  background(255);

  //tint(255, 50);
  //image(kinect.getColorImage(), 0, 0, width, height);
  body.display();

  leftHand.trackHand();
  rightHand.trackHand();

  switch(gameState) {
  case MAIN_MENU: 
    menuMode.run();
    break;
  case GAME_MODE:
    gameMode.run();
  }



  //fps(50, 50);
  //videoExport.saveFrame();
}

void triggerMethod(Trigger t) {

  switch(gameState) {
  case MAIN_MENU: 
    if (menuMode.currentMenu == 0) {
      if (t == leftHand.close) menuMode.menus.get(0).clickButton(leftHand.pos);
      if (t == rightHand.close) menuMode.menus.get(0).clickButton(rightHand.pos);
    } else if (menuMode.currentMenu == 1) {
      if (t == leftHand.close) menuMode.menus.get(1).clickButton(leftHand.pos);
      if (t == rightHand.close) menuMode.menus.get(1).clickButton(rightHand.pos);
    } else if (menuMode.currentMenu == 2) { // PLAYGROUND
      int power = 7500;
      if (t == leftHand.open) menuMode.menus.get(2).addForce(leftHand.particlePoint, -power);
      if (t == rightHand.open) menuMode.menus.get(2).addForce(rightHand.particlePoint, -power);
      if (t == leftHand.close) menuMode.menus.get(2).addForce(leftHand.particlePoint, power);
      if (t == rightHand.close) menuMode.menus.get(2).addForce(rightHand.particlePoint, power);
      if (t == rightHand.lasso || t == leftHand.lasso) menuMode.menus.get(2).removeForce();

      if (t == leftHand.close) menuMode.menus.get(2).clickButton(leftHand.pos);
      if (t == rightHand.close) menuMode.menus.get(2).clickButton(rightHand.pos);
    }
    break;
  case GAME_MODE:
    // mousePressed
    if (t == leftHand.close) {
      gameMode.gameLevels.get(0).startSelection(leftHand.pos.x, leftHand.pos.y);
      gameMode.gameLevels.get(0).mp = new PVector(leftHand.pos.x, leftHand.pos.y);
    }
    if (t == rightHand.close) {
      gameMode.gameLevels.get(0).startSelection(rightHand.pos.x, rightHand.pos.y);
      gameMode.gameLevels.get(0).mp = new PVector(rightHand.pos.x, rightHand.pos.y);
    }

    // mouseReleased
    if (t == leftHand.lasso) {
      gameMode.gameLevels.get(0).validateSelection(rightHand.pos.x, rightHand.pos.y);
    }

    if (t == rightHand.lasso) {
      gameMode.gameLevels.get(0).validateSelection(leftHand.pos.x, leftHand.pos.y);
    }
    break;
  }
}

/*
void mousePressed() {
 //gameMode.gameLevels.get(0).startSelection(mouseX, mouseY);
 }
 
 void mouseReleased() {
 //gameMode.gameLevels.get(0).validateSelection(mouseX, mouseY);
 }
 */
void keyPressed() {
  if (key == ' ' && menuMode.currentMenu == 2) menuMode.menus.get(2).resetLetters();
  if (key == ENTER) setup();
  if (key == 'm') menuMode.currentMenu = 1;
  /*if (key == 'q') {
   videoExport.endMovie();
   exit();
   }*/
}

void movieEvent(Movie m) {
  m.read();
}


void stop() {
  menuMode.bgVideo.stop();
  menuMode.bgVideo.dispose();

  kinect.closeDevice();
  kinect.dispose();
  super.exit();
}
