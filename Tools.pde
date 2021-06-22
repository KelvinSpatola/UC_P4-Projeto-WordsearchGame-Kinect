
interface StateOutput {
  abstract boolean isFinished();
  abstract void reset();
}

class Button {
  Rectangle box;
  PImage img;

  String text;
  int x, y, w, h;

  Button(String path, int x, int y, int w, int h) {
    img = loadImage(path);
    img.resize(w, h);
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    box = new Rectangle(applet, w, h);
  }

  void display() {
    push();
    imageMode(CENTER);
    translate(x - w/2, y + h/2);
    noFill();
    noStroke();
    box.get(); 
    translate(w/2, h/2);
    if (box.contains(leftHand.pos) || box.contains(rightHand.pos)) scale(1.1);
    else scale(1);
    tint(255);
    image(img, 0, 0, w, h);
    pop();
  }

  boolean contains(PVector p) {
    return box.contains(p.x, p.y);
  }
}

void fps(int x, int y) {
  push();
  textSize(30);
  translate(x, y);
  fill(#FF0000);
  text("fps: "+(int)frameRate, 0, 0);
  pop();
}

void setupVideoExport(String fileName, int fps, int quality) {
  videoExport = new VideoExport(this, fileName);
  videoExport.setDebugging(false);
  videoExport.setFrameRate(fps);
  videoExport.setQuality(quality, 0);
  videoExport.startMovie();
}
