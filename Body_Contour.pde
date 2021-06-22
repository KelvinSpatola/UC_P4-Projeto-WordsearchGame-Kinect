

class Body {
  OpenCV opencv;
  float polygonFactor = 1;
  int threshold = 10;

  //Distance in cm
  int maxD = 1600; //4.5m
  int minD = 0; //50cm

  Body(PApplet parent) {
    opencv = new OpenCV(parent, 512, 424);

    kinect.setLowThresholdPC(minD);
    kinect.setHighThresholdPC(maxD);
  }

  public void display() {
    opencv.loadImage(kinect.getPointCloudDepthImage());
    opencv.gray();
    opencv.threshold(threshold);

    push();
    scale(0.725, 1.15);
    strokeWeight(6);
    //stroke(0, 200, 200);
    stroke(160);
    //noStroke();
    fill(0, 30);
    //noFill();

    ArrayList<Contour> contours = opencv.findContours();
    if (contours.size() > 0) {
      for (Contour c : contours) {
        c.setPolygonApproximationFactor(polygonFactor);
        if (c.numPoints() > 100) {
          beginShape();
          for (PVector point : c.getPolygonApproximation().getPoints()) {
            float x = map(point.x, 0, 512, 0, width);
            float y = map(point.y, 0, 424, 0, height);
            vertex(x+435, y-50);
          }
          endShape();
        }
      }
    }
    pop();
  }
}
