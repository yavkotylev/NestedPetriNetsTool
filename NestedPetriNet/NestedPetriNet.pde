import processing.opengl.*;

Net net;
Menu menu;
float mainMaxX;
float mainMaxY;
float mainMinX;
float mainMinY;
private float scaledMainMaxX;
private float scaledMainMaxY;
String fileName;
String errorMessage;
boolean start;
boolean pressOk;
int distanceBetweenElemntsNet = 100;
void setup() {
  size(1200, 800, P3D);
  background(255);
  strokeJoin(ROUND);
  fill(255);
  strokeWeight(3);
  pressOk = true;
  start = false;
  selectInput("Select a file:", "fileSelected");  
  fileName = null;
}
void fileSelected(File selection) {
  if (selection == null) {
    exit();
  } else {    
    fileName = selection.getAbsolutePath();
    setNet(fileName);
  }
}

float scaleOfNet = 1;
float mainX = width/2;
float mainY = height/2;
float firstX = 0;
float firstY = 0;
float cornerY = 0.0;
float cornerX = -0.7;
ArrayList<ElementNet> elementArray;
void draw() {
  clear();
  background(255);
  if (pressOk == false) {
    drawMessage();
  }
  noFill();
  if (start == true && menu != null) { 
    menu.draw();
    fill(255);
    translate ((width + 330)/2, height/2, 0); 
    net.draw();
    translate (-(width + 330)/2, -height/2, 0);
  }
}

void drawMessage() {
  //errorMessage
  rect(width/2 - 200, height/2 - 100, 400, 200); 
  rect(width/2 -50, height/2 + 30, 100, 30);
  textAlign(CENTER, CENTER);
  textSize(20);
  fill(0);
  text("Okay", width/2, height/2 + 40);
  textAlign(CENTER, BOTTOM);
  text(errorMessage, width/2, height/2);
  fill(255);
}

void mouseMoved() {
  if (start == true && menu != null) {
    if (menu.visible == true) {
      if (mouseX >= 330) {
        menu.visible = false;
      }      
      if (mouseX >= 0 && mouseX <= 300 && mouseY >=70) {
        for (int i = 0; i < menu.elementsMenu.size(); i++) {
          if (menu.elementsMenu.get(i).topY > height - 70 || menu.elementsMenu.get(i).checkPoint(mouseY)) {
          }
        }
      } else {        
        for (int i = 0; i < menu.elementsMenu.size(); i++) {
          menu.elementsMenu.get(i).net.highlighted = false;
        }
      }
    } else {
      if (mouseX <= 32 && elementArray.size() != 0) {
        menu.visible = true;
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (start == true && menu != null) {
    float e = event.getCount();
    if (mouseX >= 330 || menu.visible == false) {
      if (e >= 1 && scaleOfNet >= 0) {
        scaleOfNet /= 1.02;
      } else {
        scaleOfNet *= 1.02;
      }
      scaledMainMaxX = mainMaxX * scaleOfNet;
      scaledMainMaxY = mainMaxY * scaleOfNet;
      net.scaleChanged(scaleOfNet);
    }
    if (mouseX < 330 && menu.visible == true) {
      if (e >= 1) {
        menu.down.active = true;
        menu.scroll(4);
        menu.down.active = false;
      } else {       
        menu.up.active = true;
        menu.scroll(4);
        menu.up.active = false;
        return;
      }
    }
  }
}

void mousePressed() {
  if (start == true && menu != null) {
    if (mouseButton == LEFT) {
      firstX = mouseX;
      firstY = mouseY;
    }
    if (mouseButton == LEFT) {
      if (menu.visible == true && mouseX <= 325 && mouseX >= 305 && mouseY <=45 && mouseY >= 25) {
        menu.drawRectangle = !menu.drawRectangle;  
        return;
      }
      if (menu.visible == false && mouseX >= 0 && mouseX <= 32 && mouseY >= 0 && mouseY <=32 && elementArray.size() != 0) {
        menu.visible = true;
        return;
      }
      if (mouseX >= 260 && mouseX <= 275 && menu.visible == true) {
        for (int i = 0; i < menu.elementsMenu.size(); i++) {
          if (menu.elementsMenu.get(i).checkPress (mouseY) == true) {
            return;
          }
        }
      }
      if (mouseX >= 300 && mouseX <= 330 && menu.visible == true) {
        if (mouseY >= 70 && mouseY <= 105) {
          menu.up.active = true;
          return;
        } 
        if (mouseY >= height - 35) {
          menu.down.active = true;
          return;
        }
      }
    }
  } else {
    if (pressOk == false && mouseX >= width/2 -50 && mouseX <= width/2 + 50 && mouseY >= height/2 + 30 && mouseY <= height/2 + 60 ) {
      pressOk = true;
      selectInput("Select a file to process:", "fileSelected");
    }
  }
}

void mouseReleased() {
  if (mouseButton == LEFT && start == true && menu != null && elementArray.size() != 0) {
    menu.disableActiveButton();
  }
}


public class Menu {
  ArrayList<ElementMenu> elementsMenu;
  ElementMenu top;
  ElementMenu low;
  ElementNet activeNet;
  Arrow up;
  Arrow down;
  Runner runner;
  boolean visible;
  boolean drawRectangle;

  public Menu() {
    if (elementArray.size() == 0) {
      return;
    }
    elementsMenu = new ArrayList<ElementMenu>();
    for (int i = 0; i < elementArray.size(); i++) {
      elementsMenu.add(new ElementMenu(70 + i * 40, elementArray.get(i)));
    }
    top = elementsMenu.get(0);
    low = elementsMenu.get(elementsMenu.size() - 1);
    up = new Arrow("up");
    down = new Arrow("down");
    runner = new Runner(top.topY, low.lowY);
    visible = true;
  }

  void draw() {
    if (visible == false) {
      rect(0, 0, 32, 32);
      line(3, 8, 29, 8);
      line(3, 16, 29, 16);
      line(3, 24, 29, 24);
      return;
    }
    if (up.active == true || down.active == true) {
      scroll(2);
    }
    translate(0, 0, 1);
    strokeCap(ROUND);
    if (drawRectangle == true) {
      fill(0, 200, 0);
      rect(305, 25, 20, 20);
    } else {
      noFill();
      rect(305, 25, 20, 20);
    }
    translate(0, 0, -1);
    noFill();
    rect(0, 70, 330, height - 70);
    rect(300, 70, 30, height - 70);
    fill(255);
    for (int i = 0; i < elementsMenu.size(); i++) {
      elementsMenu.get(i).draw();
    }
    strokeWeight(3);
    rect(0, 0, 330, 70);
    noFill();
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(30);
    text("Element nets:", 150, 35);
    fill(255);
    up.draw();
    down.draw();
    runner.draw();
  }

  void disableActiveButton() {
    if (down.active == true) {
      down.active = false;
      return;
    }
    if (up.active == true) {
      up.active = false;
      return;
    }
  }

  void scroll(int speed) {
    if (top.topY < 70 || low.lowY > height) {
      if (down.active == true && low.lowY >= height) {
        for (int i = 0; i < elementsMenu.size(); i++) {
          elementsMenu.get(i).pickUp(speed);
        }
        runner.pickUp(speed);
        return;
      }

      if (up.active == true && top.topY < 70) {
        for (int i = 0; i < elementsMenu.size(); i++) {
          elementsMenu.get(i).drop(speed);
        }
        runner.drop(speed);
      }
    }
  }
}

public class ElementMenu {
  float topY;
  float lowY;
  ElementNet net;

  ElementMenu(float top, ElementNet net) {
    topY = top;
    lowY = top + 40;
    this.net = net;
  }

  void pickUp(int i) {

    topY -= i;
    lowY -= i;
  }

  void drop(int i) {
    topY += i;
    lowY += i;
  }

  boolean checkPoint(float y) {
    if (net.visible == false) {
      return false;
    }
    if (y < lowY && y >= topY) {
      net.highlighted = true;
      return true;
    } else {
      if (net.highlighted == true) {
        net.highlighted = false;
      }
      return false;
    }
  }

  boolean checkPress(float y) {
    if (y >= topY + 13 && y <= topY + 28) {
      net.visible = !net.visible;
      return true;
    }
    return false;
  }

  void draw() {
    fill(255);
    if (lowY < 70) {
      return;
    }
    strokeWeight(1);
    line(10, lowY, 290, lowY);
    textSize(20);
    fill(0);
    textAlign(LEFT, CENTER);
    text(net.name, 10, (topY + lowY) / 2);
    if (net.visible == true) {
      fill(net.uniqueColor);
    } else {
      fill(255);
    }
    if (topY <= 57 && topY >= 42) {
      rect(260, 70, 15, topY - 42);
      fill(255);
      return;
    }
    if (topY < 42) {
      fill(255);
      return;
    }
    rect(260, topY + 13, 15, 15);
    fill(255);
  }
}

public class Arrow {
  float x;
  float y;
  float rectWidth;
  float rectHeight;
  boolean active;
  float triangleX1;
  float triangleY1;
  float triangleX2;
  float triangleY2;
  float triangleX3;
  float triangleY3;

  public Arrow(String str) {
    this.rectWidth = 30;
    this.rectHeight = 35;
    this.x = 300;
    triangleX1 = 305;
    triangleX2 = 315;
    triangleX3 = 325;
    if (str.equals("up")) {
      this.y = 70;
      triangleY1 = 98;
      triangleY2 = 78;
      triangleY3 = 98;
    }
    if (str.equals("down")) {
      this.y = height - 35;
      triangleY1 = height - 28;
      triangleY2 = height - 8;
      triangleY3 = height - 28;
    }
  }

  void draw() {
    if (this.active == true) {
      fill(210);
    } else {
      fill(255);
    }
    rect(this.x, this.y, rectWidth, rectHeight);
    fill(0);
    triangle(triangleX1, triangleY1, triangleX2, triangleY2, triangleX3, triangleY3);
    fill(255);
  }
}

class Runner {
  float x;
  float y;
  float runnerWidth;
  float runnerHeight;
  float numerator;
  float denominator;
  boolean mooving = false;

  public Runner(float topY, float lowY) {
    x = 304;
    y = 109;
    runnerWidth = 22;

    if (lowY - topY <= height - 70) {
      runnerHeight = height - 39 - y;
      denominator = lowY - topY - runnerHeight;
    } else {
      runnerHeight = pow((height - 70 + 15 - y), 2) / (lowY - topY);
      denominator = lowY - topY - runnerHeight;
    }
    numerator = height - 217;
  }

  void pickUp(int i) {
    y += i * numerator / denominator;
  }

  void drop(int i) {
    y -= i * numerator / denominator;
  }

  void draw() {
    fill(0);
    strokeWeight(1);
    rect(x, y, runnerWidth, runnerHeight);
    strokeWeight(3);
    fill(255);
  }
}



public class Token {
  public Token(float y, float diameter, int level, String name, int num, int size) {
    this.level = level;
    this.name = name;
    if (size == 1) {
      this.y = y;
      this.scaledTokenY = y;
      this.diameter = diameter / 5;
      this.scaledTokenDiameter = this.diameter;
      return;
    }
    if (size == 2) {
      if (num == 1) {
        this.y = y - diameter / 6;
        this.scaledTokenY = y;
        this.diameter = diameter / 6;
        this.scaledTokenDiameter = this.diameter;
      }
      if (num == 2) {
        this.y = y + diameter / 6;
        this.scaledTokenY = y;
        this.diameter = diameter / 6;
        this.scaledTokenDiameter = this.diameter;
      }
      return;
    }
    this.y = y;
    this.scaledTokenY = y;
    this.diameter = diameter;
    this.scaledTokenDiameter = this.diameter;
  }

  public int level;
  public float x;
  public float y;
  public float diameter;
  float scaledTokenX;
  float scaledTokenY;
  float scaledTokenDiameter;
  String name;

  public void changeScale(float scale) {
    scaledTokenX = this.x * scale - scaledMainMaxX / 2;
    scaledTokenY = this.y * scale - scaledMainMaxY / 2;
    scaledTokenDiameter = this.diameter * scale;
  }
}

public class DeactivateToken extends Token {
  public DeactivateToken(float x, float y, float diameter, int level, String name, int num, int size) {
    super(y, diameter, level, name, num, size);
    if (size == 1 || (size == 2 && (num == 1 || num == 2))) {
      this.x = x + diameter / 4;
    } else {
      this.x = x;
    }
  }

  public void changeScale(float scale) {
    super.changeScale(scale);
  }

  public void draw(int number, int size) {
    color c = g.fillColor;
    translate(0, 0, 1 * scaleOfNet);
    fill(0);
    if (size == 1 || (size == 2 && (number == 1 || number == 2))) {
      ellipse(scaledTokenX, scaledTokenY, scaledTokenDiameter, scaledTokenDiameter);
    }
    fill(c);
    translate(0, 0, -1 * scaleOfNet);
  }
} 

public class ActiveToken extends Token {
  public ActiveToken(float x, float y, float diameter, int level, String name, String idElementNet, int num, int size) {
    super(y, diameter, level, name, num, size);
    this.idElementNet = idElementNet;
    if (size == 1 || (size == 2 && (num == 1 || num == 2))) {
      this.x = x - diameter / 4;
    } else {
      this.x = x;
    }
  }

  public void changeScale(float scale) {
    super.changeScale(scale);
    elementNet.changeScale(scale);
  }

  public void draw(int number, int size) {
    color c = g.fillColor;
    translate(0, 0, 1 * scaleOfNet);
    fill(255);
    if (size == 1 || (size == 2 && (number == 1 || number == 2))) {
      ellipse(scaledTokenX, scaledTokenY, scaledTokenDiameter, scaledTokenDiameter);
    }
    fill(c);
    translate(0, 0, -1 * scaleOfNet);
    elementNet.draw();
  }

  String idElementNet;
  public ElementNet elementNet;
}


public class Place {
  public Place(float x, float y, float diameter, int level) {
    this.placeX = x;
    this.placeY = y;
    this.placeDiameter = diameter;
    this.level = level;
    this.placeRadius = diameter / 2;

    this.scaledPlaceX = this.placeX;
    this.scaledPlaceY = this.placeY;
    this.scaledPlaceDiameter = this.placeDiameter;
    this.scaledPlaceRadius = this.placeRadius;
    deactivateTokens = new ArrayList<DeactivateToken>();
    activeTokens = new ArrayList<ActiveToken>();
  }

  public ArrayList<DeactivateToken> deactivateTokens;
  public ArrayList<ActiveToken> activeTokens;
  public float placeX;
  public float placeY;
  public float placeDiameter;
  public float placeRadius;

  public float scaledPlaceX;
  public float scaledPlaceY;
  public float scaledPlaceDiameter;
  public float scaledPlaceRadius;

  public int level;
  String id;
  String name;

  public void changeScale(float scale) {
    scaledPlaceX = placeX * scale - scaledMainMaxX / 2;
    scaledPlaceY = placeY * scale - scaledMainMaxY / 2;
    scaledPlaceRadius = placeRadius * scale;
    scaledPlaceDiameter = placeDiameter * scale;
    for (int i = 0; i < activeTokens.size(); i++) {
      activeTokens.get(i).changeScale(scale);
    }
  }

  public void draw(int level) {

    translate(0, 0, distanceBetweenElemntsNet * level * scaleOfNet);
    color c = g.fillColor;
    ellipse((scaledPlaceX), (scaledPlaceY), scaledPlaceDiameter, scaledPlaceDiameter);

    if (deactivateTokens.size() > 2 || activeTokens.size() > 2) {
      translate(0, 0, 1 * scaleOfNet);
      line((scaledPlaceX), (scaledPlaceY + scaledPlaceDiameter / 2), (scaledPlaceX), 
        (scaledPlaceY - scaledPlaceDiameter / 2));
      fill(0);

      textAlign(CENTER, CENTER);
      textSize(scaledPlaceRadius / 2);
      if (activeTokens.size() > 2) {
        fill(0);
        text(activeTokens.size(), (scaledPlaceX - scaledPlaceRadius / 2), (scaledPlaceY + scaledPlaceRadius / 2));
        fill(255);
        ellipse((scaledPlaceX - scaledPlaceRadius / 2), (scaledPlaceY - scaledPlaceRadius / 2), 
          scaledPlaceRadius / 3, scaledPlaceRadius / 3);
      }
      if (deactivateTokens.size() > 2) {
        fill(0);
        text(deactivateTokens.size(), (scaledPlaceX + scaledPlaceRadius / 2), (scaledPlaceY + scaledPlaceRadius / 2));
        fill(0);
        ellipse((scaledPlaceX + scaledPlaceRadius / 2), (scaledPlaceY - scaledPlaceRadius / 2), 
          scaledPlaceRadius / 3, scaledPlaceRadius / 3);
      }
      fill(c);
      translate(0, 0, -1 * scaleOfNet);
    }

    if (deactivateTokens.size() < 3) {
      for (int i = 0; i < deactivateTokens.size(); i++) {
        deactivateTokens.get(i).draw(i + 1, deactivateTokens.size());
      }
    }
    for (int i = 0; i < activeTokens.size(); i++) {
      activeTokens.get(i).draw(i + 1, activeTokens.size());
    }
    fill(0);
    translate(0, 0, 0.001);
    textSize(scaledPlaceDiameter / 5);
    textAlign(CENTER, TOP);
    text(id, scaledPlaceX, scaledPlaceY + scaledPlaceDiameter / 2);
    fill(c);
    translate(0, 0, -0.001);
    translate(0, 0, -distanceBetweenElemntsNet * level * scaleOfNet);
  }

  void shift(float amendmentX, float amendmentY) {
    this.placeX += amendmentX;
    this.placeY += amendmentY;
    this.scaledPlaceX = this.placeX * scaleOfNet;
    this.scaledPlaceY = this.placeY * scaleOfNet;
    for (int i = 0; i < deactivateTokens.size(); i++) {
      deactivateTokens.get(i).x += amendmentX;
      deactivateTokens.get(i).y += amendmentY;
    }

    for (int i = 0; i < activeTokens.size(); i++) {
      activeTokens.get(i).x += amendmentX;
      activeTokens.get(i).y += amendmentY;
    }
  }
}


public class Transition {
  public Transition(float x, float y, float radiusX, float radiusY, int level) {
    this.transitionX = x;
    this.transitionY = y;
    this.transitionRadiusX = radiusX;
    this.transitionRadiusY = radiusY;

    this.scaledTransitionX = transitionX;
    this.scaledTransitionY = transitionY;
    this.scaledTransitionRadiusX = transitionRadiusX;
    this.scaledTransitionRadiusY = transitionRadiusY;
    this.level = level;
  }

  public float transitionX;
  public float transitionY;
  public float transitionRadiusX;
  public float transitionRadiusY;

  private float scaledTransitionX;
  private float scaledTransitionY;
  private float scaledTransitionRadiusX;
  private float scaledTransitionRadiusY;
  public int level;
  String id;
  String name;

  public void changeScale(float scale) {
    this.scaledTransitionX = transitionX * scale - scaledMainMaxX / 2;
    this.scaledTransitionY = transitionY * scale - scaledMainMaxY / 2;
    this.scaledTransitionRadiusX = transitionRadiusX * scale;
    this.scaledTransitionRadiusY = transitionRadiusY * scale;
  }

  void shift(float amendmentX, float amendmentY) {
    this.transitionX += amendmentX;
    this.transitionY += amendmentY;
    this.changeScale(scaleOfNet);
  }

  public void draw(int level) {
    translate(0, 0, distanceBetweenElemntsNet * level * scaleOfNet);
    rect(scaledTransitionX, scaledTransitionY, scaledTransitionRadiusX, scaledTransitionRadiusY);
    color c = g.fillColor;
    fill(0);
    translate(0, 0, 0.001);
    textSize((scaledTransitionRadiusX < scaledTransitionRadiusY) ? (scaledTransitionRadiusX / 5) : (scaledTransitionRadiusY / 5));
    if (name != null) {
      textAlign(CENTER, TOP);
      text(name, scaledTransitionX + scaledTransitionRadiusX / 2, scaledTransitionY + scaledTransitionRadiusY);
    }
    fill(c);
    translate(0, 0, -0.001);
    translate(0, 0, -distanceBetweenElemntsNet * level * scaleOfNet);
  }
}


public class ElementNet {
  public ElementNet(ActiveToken token, int level) {
    this.level = level;
    this.token = token;
    transitions = new ArrayList<Transition>();
    arcs = new ArrayList<Arc>();
    places = new ArrayList<Place>();
    highlighted = false;
    name = "Name of this net: " + (elementArray.size() + 1);
    visible = false;
    uniqueColor = color(random(0, 255), random(0, 255), random(0, 255));
  }

  Transition beginTr;
  Place beginPl;
  Transition endTr;
  Place endPl;

  private float getBeginX() {
    if (beginPl != null) {
      return beginPl.scaledPlaceX;
    }
    if (beginTr != null) {
      return beginTr.scaledTransitionX;
    }
    return 0.0;
  }

  private float getBeginY() {
    if (beginPl != null) {
      return beginPl.scaledPlaceY;
    }
    if (beginTr != null) {
      return beginTr.scaledTransitionY;
    }
    return 0.0;
  }

  private float getEndX() {
    if (endPl != null) {
      return endPl.scaledPlaceX;
    }
    if (endTr != null) {
      return endTr.scaledTransitionX;
    }
    return 0.0;
  }

  private float getEndY() {
    if (endPl != null) {
      return endPl.scaledPlaceY;
    }
    if (endTr != null) {
      return endTr.scaledTransitionY;
    }
    return 0.0;
  }

  private float getEndDistance() {
    if (endPl != null) {
      return endPl.scaledPlaceRadius;
    }
    if (endTr != null) {
      return endTr.scaledTransitionRadiusX;
    }
    return 0.0;
  }

  public color uniqueColor;
  public boolean highlighted;
  public boolean visible;
  public int level;
  public ActiveToken token;
  public ArrayList<Transition> transitions;
  public ArrayList<Arc> arcs;
  public ArrayList<Place> places;
  public String name;
  float diameterX;
  float diameterY;
  float rectX;
  float rectY;

  public void changeScale(float scale) {
    for (int i = 0; i < transitions.size(); i++) {
      transitions.get(i).changeScale(scale);
    }
    for (int i = 0; i < places.size(); i++) {
      places.get(i).changeScale(scale);
    }
  }

  public void draw() {
    if (visible == true) {
      if (highlighted == true) {
        stroke(uniqueColor);
        fill(uniqueColor);
      } else {
        fill(240);
      }
      line(token.scaledTokenX, token.scaledTokenY, token.level * distanceBetweenElemntsNet * scaleOfNet, 
        (this.getBeginX()), this.getBeginY(), level * distanceBetweenElemntsNet * scaleOfNet);
      for (int i = 0; i < places.size(); i++) {
        places.get(i).draw(level);
      }
      for (int i = 0; i < transitions.size(); i++) {
        transitions.get(i).draw(level);
      }
      for (int i = 0; i < arcs.size(); i++) {
        arcs.get(i).draw(level);
      }

      line(this.getEndX() + this.getEndDistance(), this.getEndY(), level * distanceBetweenElemntsNet * scaleOfNet, 
        token.scaledTokenX, token.scaledTokenY, token.level * distanceBetweenElemntsNet * scaleOfNet);
      fill(255);
      if (menu.drawRectangle == true) {
        translate(0, 0, -1 + level * scaleOfNet * distanceBetweenElemntsNet);
        rect((rectX - 50 - mainMaxX / 2) * scaleOfNet, (rectY - 50 - mainMaxY / 2) * scaleOfNet, (diameterX + 100) * scaleOfNet, (diameterY + 50) * scaleOfNet);
        translate(0, 0, 1 - level * scaleOfNet * distanceBetweenElemntsNet);
      }
      stroke(0);
    }
  }

  void shift() {
    float tokenX = token.x;
    float tokenY = token.y;
    float maxX1 = transitions.get(0).transitionX;
    float maxY1 = transitions.get(0).transitionY;
    float minX1 = maxX1;
    float minY1 = maxY1;
    for (int i = 0; i < transitions.size(); i++) {
      if (transitions.get(i).transitionX > maxX1) {
        maxX1 = transitions.get(i).transitionX;
      }
      if (transitions.get(i).transitionY > maxY1) {
        maxY1 = transitions.get(i).transitionY;
      }

      if (transitions.get(i).transitionX < minX1) {
        minX1 = transitions.get(i).transitionX;
      }

      if (transitions.get(i).transitionY < minY1) {
        minY1 = transitions.get(i).transitionY;
      }
    }
    for (int i = 0; i < places.size(); i++) {
      if (places.get(i).placeX > maxX1) {
        maxX1 = places.get(i).placeX;
      }
      if (places.get(i).placeY > maxY1) {
        maxY1 = places.get(i).placeY;
      }

      if (places.get(i).placeX < minX1) {
        minX1 = places.get(i).placeX;
      }

      if (places.get(i).placeY < minY1) {
        minY1 = places.get(i).placeY;
      }
    }
    diameterX = maxX1 - minX1 + 70;
    diameterY = maxY1 - minY1 + 70;
    float amendmentX = tokenX - (maxX1 + minX1) / 2;
    float amendmentY = tokenY - (maxY1 + minY1) / 2;
    rectX = amendmentX;
    rectY = amendmentY;
    for (int i = 0; i < transitions.size(); i++) {
      transitions.get(i).shift(amendmentX, amendmentY);
    }
    for (int i = 0; i < places.size(); i++) {
      places.get(i).shift(amendmentX, amendmentY);
    }
  }
}

public class Arc {
  public Arc(Place pl, Transition tr) {
    trans = tr;
    place = pl;
    level = pl.level;
    coordinateZ = level * distanceBetweenElemntsNet;
  }

  public Transition trans;
  public Place place;
  int level;
  float coordinateZ;
  String id;
  String source;
  String target;
  String name;
  String type;

  public void draw(int i) {
    if (type.equals("circular")) {
      color c = g.fillColor;
      noFill();
      translate(0, 0, i * scaleOfNet * distanceBetweenElemntsNet);
      ellipse(place.scaledPlaceX, (place.scaledPlaceY + place.scaledPlaceDiameter), 
        place.scaledPlaceRadius * 0.9, place.scaledPlaceDiameter);
      translate(0, 0, 0.003);
      float x1 = place.scaledPlaceX;
      float y1 = place.scaledPlaceY;
      float x0 = place.scaledPlaceX;
      float y0 = (place.scaledPlaceY + place.scaledPlaceRadius);
      float beginHeadSize = place.scaledPlaceDiameter / 15;
      PVector d = new PVector(x1 - x0, y1 - y0);
      d.normalize();
      float coeff = 3.0;
      strokeCap(SQUARE);
      float angle = atan2(d.y, d.x);
      // begin head
      fill(0);
      pushMatrix();
      translate(x0, y0, 0.00001);
      rotate(angle + PI / 180 * 47);
      triangle(-beginHeadSize * coeff, -beginHeadSize, 
        -beginHeadSize * coeff, beginHeadSize, 
        0, 0);
      popMatrix();
      strokeWeight(1.2 * sqrt(scaleOfNet / 2));
      translate(0, 0, -0.003);
      fill(c);
      translate(0, 0, -i * scaleOfNet * distanceBetweenElemntsNet);
      return;
    }
    float rectX = -place.scaledPlaceX + trans.scaledTransitionX;
    float rectY = -place.scaledPlaceY + trans.scaledTransitionY;
    float circleX = 0;
    float circleY = 0;
    //rext on the left of ellipse
    if (rectX < 0) {
      rectX += trans.scaledTransitionRadiusX;
    }

    rectY += trans.scaledTransitionRadiusY / 2;
    float hypotenuse = sqrt((rectX * rectX) + (rectY * rectY));
    float sine = rectY / hypotenuse;
    float cosine = rectX / hypotenuse;
    circleX = place.scaledPlaceX + cosine * place.scaledPlaceRadius;
    circleY = place.scaledPlaceY + sine * place.scaledPlaceRadius;

    translate(0, 0, i * scaleOfNet * distanceBetweenElemntsNet);
    line((rectX + place.scaledPlaceX), (rectY + place.scaledPlaceY), (circleX), 
      circleY);
    if (target.equals(trans.id) && source.equals(place.id)) {
      drawArrow((rectX + place.scaledPlaceX), (rectY + place.scaledPlaceY), circleX, 
        (circleY), place.scaledPlaceDiameter / 15, 0, true);
    }
    if (target.equals(place.id) && source.equals(trans.id)) {
      drawArrow((rectX + place.scaledPlaceX), (rectY + place.scaledPlaceY), circleX, 
        circleY, 0, place.scaledPlaceDiameter / 15, true);
    }
    textAlign(CENTER, TOP);
    textSize(place.scaledPlaceDiameter / 5);
    color c = g.fillColor;
    fill(0);
    rectY += trans.scaledTransitionRadiusY / 2;
    text(name, (rectX + place.scaledPlaceX + circleX) / 2, (rectY + place.scaledPlaceY + circleY) / 2);
    fill(c);
    translate(0, 0, -i * scaleOfNet * distanceBetweenElemntsNet);
  }

  void drawArrow(float x0, float y0, float x1, float y1, float beginHeadSize, float endHeadSize, boolean filled) {
    PVector d = new PVector(x1 - x0, y1 - y0);
    d.normalize();
    float coeff = 5.0;
    strokeCap(SQUARE);
    float angle = atan2(d.y, d.x);
    if (filled) {
      // begin head
      fill(0);
      pushMatrix();
      translate(x0, y0, 0.00001);
      rotate(angle + PI);
      triangle(-beginHeadSize * coeff, -beginHeadSize, 
        -beginHeadSize * coeff, beginHeadSize, 
        0, 0);
      popMatrix();
      // end head
      pushMatrix();
      translate(x1, y1, 0.00001);
      rotate(angle);
      triangle(-endHeadSize * coeff, -endHeadSize, 
        -endHeadSize * coeff, endHeadSize, 
        0, 0);
      popMatrix();
      fill(255);
    } else {
      // begin head
      pushMatrix();
      translate(x0, y0);
      rotate(angle + PI);
      strokeCap(ROUND);
      line(-beginHeadSize * coeff, -beginHeadSize, 0, 0);
      line(-beginHeadSize * coeff, beginHeadSize, 0, 0);
      popMatrix();
      // end head
      pushMatrix();
      translate(x1, y1);
      rotate(angle);
      strokeCap(ROUND);
      line(-endHeadSize * coeff, -endHeadSize, 0, 0);
      line(-endHeadSize * coeff, endHeadSize, 0, 0);
      popMatrix();
    }
    strokeWeight(1.2 * sqrt(scaleOfNet / 2));
  }
}

public class Net {
  public Net() {
    places = new ArrayList<Place>();
    transitions = new ArrayList<Transition>();
    arcs = new ArrayList<Arc>();
  }

  String name;
  public ArrayList<Place> places;
  public ArrayList<Transition> transitions;
  public ArrayList<Arc> arcs;

  public void scaleChanged(float scale) {
    for (int i = 0; i < transitions.size(); i++) {
      transitions.get(i).changeScale(scale);
    }

    for (int i = 0; i < places.size(); i++) {
      places.get(i).changeScale(scale);
    }
  }

  public void draw() {
    if (mousePressed) {
      if (mouseButton == LEFT) {
        if ((mouseX > 330 && firstX > 330) || menu.visible == false) {
          mainX += (-firstX + mouseX);
          mainY += (-firstY + mouseY);
          firstX = mouseX;
          firstY = mouseY;
        }
        if (mouseX <= 330 && firstX > 330) {
          firstX = 331;
          firstY = mouseY;
        }
      }
    }

    if (keyPressed) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          cornerY += -0.01;
        }
        if (keyCode == LEFT) {
          cornerY += 0.01;
        }
        if (keyCode == UP) {
          cornerX += -0.01;
        }
        if (keyCode == DOWN) {
          cornerX += 0.01;
        }
      }
    }
    strokeWeight(1.2 * sqrt(scaleOfNet / 2));
    translate(mainX, mainY, 0);
    rotateY(-cornerY);
    rotateX(-cornerX);
    for (int i = 0; i < places.size(); i++) {
      places.get(i).draw(0);
    }

    for (int i = 0; i < transitions.size(); i++) {
      transitions.get(i).draw(0);
    }

    for (int i = 0; i < arcs.size(); i++) {
      arcs.get(i).draw(0);
    }
    rotateX(cornerX);
    rotateY(cornerY);

    translate(-mainX, -mainY, 0);
    strokeWeight(3);
  }
}


public void setNet(String selection) {
  elementArray = new ArrayList<ElementNet>();
  net = new Net();
  XML xml = null;
  try {
    xml = loadXML(selection);
    start = true;
  } 
  catch (Exception e) {
    start = false;
    pressOk = false;
    errorMessage = "Error!\nWrong way!";
  }

  //Load main net
  XML[] nets = null;
  try {
    nets = xml.getChildren("net");
    net.name = nets[0].getChildren("name")[0].getChildren("text")[0].getContent();
    //Load places
    XML[] places = null;
    places = nets[0].getChildren("place");
    for (int i = 0; i < places.length; i++) {
      String id = places[i].getString("id");
      String name;
      try {
        name = places[i].getChildren("name")[0].getChildren("text")[0].getContent();
      } 
      catch (Exception e) {
        name = null;
      }
      float x = places[i].getChildren("graphics")[0].getChildren("position")[0].getFloat("x");
      float y = places[i].getChildren("graphics")[0].getChildren("position")[0].getFloat("y");
      float dimensionX = places[i].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("x");
      //float dimensionY= places[i].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("y");
      Place place = new Place(x, y, dimensionX, 0);
      place.name = name;
      place.id = id;
      XML[] markings = places[i].getChildren("initialMarking");
      int sizeActive = 0;
      int sizeDeactivate = 0;
      int numActive = 0;
      int numDeactivate = 0;
      for (int j = 0; j < markings.length; j++) {
        if (markings[j].getString("type").equals("active")) {
          sizeActive++;
        }
        if (markings[j].getString("type").equals("deactivate")) {
          sizeDeactivate++;
        }
      }
      for (int j = 0; j < markings.length; j++) {
        if (markings[j].getString("type").equals("active")) {
          ActiveToken t = new ActiveToken(place.placeX, place.placeY, place.placeDiameter, 0, 
            markings[j].getChildren("text")[0].getContent(), markings[j].getChildren("elementNet")[0].getContent(), ++numActive, sizeActive);
          place.activeTokens.add(t);
        }
        if (markings[j].getString("type").equals("deactivate")) {
          place.deactivateTokens.add(new DeactivateToken(place.placeX, place.placeY, place.placeDiameter, 0, 
            markings[j].getChildren("text")[0].getContent(), ++numDeactivate, sizeDeactivate));
        }
      }
      net.places.add(place);
    }

    //load transitions
    XML[] transitions = null;
    transitions = nets[0].getChildren("transition");
    for (int i = 0; i < transitions.length; i++) {
      String id = transitions[i].getString("id");
      String name;
      try {
        name = transitions[i].getChildren("name")[0].getChildren("text")[0].getContent();
      } 
      catch (Exception e) {
        name = null;
      }
      float x = transitions[i].getChildren("graphics")[0].getChildren("position")[0].getFloat("x");
      float y = transitions[i].getChildren("graphics")[0].getChildren("position")[0].getFloat("y");
      float radiusX = transitions[i].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("x");
      float radiusY = transitions[i].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("y");
      Transition transition = new Transition(x, y, radiusX, radiusY, 0);
      transition.id = id;
      transition.name = name;
      net.transitions.add(transition);
    }

    //load arcs
    XML[] arcs = null;
    arcs = nets[0].getChildren("arc");
    for (int i = 0; i < arcs.length; i++) {
      String id = arcs[i].getString("id");
      String source = arcs[i].getString("source");
      String target = arcs[i].getString("target");
      String name = arcs[i].getChildren("name")[0].getChildren("text")[0].getContent();
      String type = arcs[i].getChildren("arctype")[0].getChildren("text")[0].getContent();
      Transition tr = null;
      Place pl = null;
      for (int j = 0; j < net.places.size(); j++) {
        if (target.equals(net.places.get(j).id) || source.equals(net.places.get(j).id)) {
          pl = net.places.get(j);
        }
      }

      for (int j = 0; j < net.transitions.size(); j++) {
        if (target.equals(net.transitions.get(j).id) || source.equals(net.transitions.get(j).id)) {
          tr = net.transitions.get(j);
        }
      }
      Arc arc = new Arc(pl, tr);
      arc.source = source;
      arc.target = target;
      arc.name = name;
      arc.type = type;
      arc.id = id;
      net.arcs.add(arc);
    }

    //load elementnets
    XML[] elementNets = null;
    elementNets = xml.getChildren("elementNet");
    for (int i = 0; i < elementNets.length; i++) {
      String id = elementNets[i].getString("id");
      ElementNet elem = null;
      for (int j = 0; j < net.places.size(); j++) {
        for (int k = 0; k < net.places.get(j).activeTokens.size(); k++) {
          if (net.places.get(j).activeTokens.get(k).idElementNet.equals(id)) {
            elem = new ElementNet(net.places.get(j).activeTokens.get(k), elementArray.size() + 1);
            elem.name = elementNets[i].getChildren("name")[0].getChildren("text")[0].getContent();
            elementArray.add(elem);
            net.places.get(j).activeTokens.get(k).elementNet = elem;
            break;
          }
        }
      }

      //load places
      XML[] placesElement = elementNets[i].getChildren("place");
      for (int q = 0; q < placesElement.length; q++) {
        String idElement = placesElement[q].getString("id");
        String nameElement;
        try {
          nameElement = placesElement[q].getChildren("name")[0].getChildren("text")[0].getContent();
        } 
        catch (Exception e) {
          nameElement = null;
        }
        float xElement = placesElement[q].getChildren("graphics")[0].getChildren("position")[0].getFloat("x");
        float yElement = placesElement[q].getChildren("graphics")[0].getChildren("position")[0].getFloat("y");
        float dimensionXElement = placesElement[q].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("x");
        float dimensionYElement = placesElement[q].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("y");
        Place placeElement = new Place(xElement, yElement, dimensionXElement, 0);
        if (placesElement[q].getChildren("begin").length != 0) {
          elem.beginPl = placeElement;
          elem.beginTr = null;
        }
        if (placesElement[q].getChildren("end").length != 0) {
          elem.endPl = placeElement;
          elem.endTr = null;
        }
        placeElement.name = nameElement;
        placeElement.id = idElement;
        XML[] markingsElement = placesElement[q].getChildren("initialMarking");
        int sizeActiveElement = 0;
        int sizeDeactivateElement = 0;
        int numActiveElement = 0;
        int numDeactivateElement = 0;
        for (int j = 0; j < markingsElement.length; j++) {
          if (markingsElement[j].getString("type").equals("active")) {
            sizeActiveElement++;
          }
          if (markingsElement[j].getString("type").equals("deactivate")) {
            sizeDeactivateElement++;
          }
        }
        for (int j = 0; j < markingsElement.length; j++) {
          if (markingsElement[j].getString("type").equals("active")) {
            ActiveToken tElement = new ActiveToken(placeElement.placeX, placeElement.placeY, placeElement.placeDiameter, 0, 
              markingsElement[j].getChildren("text")[0].getContent(), markingsElement[j].getChildren("elementNet")[0].getContent(), 
              ++numActiveElement, sizeActiveElement);
            placeElement.activeTokens.add(tElement);
          }
          if (markingsElement[j].getString("type").equals("deactivate")) {
            placeElement.deactivateTokens.add(new DeactivateToken(placeElement.placeX, placeElement.placeY, placeElement.placeDiameter, 0, 
              markingsElement[j].getChildren("text")[0].getContent(), ++numDeactivateElement, sizeDeactivateElement));
          }
        }
        elem.places.add(placeElement);
      }
      try {

        //load transitions
        XML[] transitionsElement = elementNets[i].getChildren("transition");
        for (int q = 0; q < transitionsElement.length; q++) {
          try {
            String idElement = transitionsElement[q].getString("id");
            String nameElement;
            try {
              nameElement = transitionsElement[q].getChildren("name")[0].getChildren("text")[0].getContent();
            } 
            catch (Exception e) {
              nameElement = null;
            }

            float xElement = transitionsElement[q].getChildren("graphics")[0].getChildren("position")[0].getFloat("x");
            float yElement = transitionsElement[q].getChildren("graphics")[0].getChildren("position")[0].getFloat("y");
            float radiusXElement = transitionsElement[q].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("x");
            float radiusYElement = transitionsElement[q].getChildren("graphics")[0].getChildren("dimension")[0].getFloat("y");
            Transition transitionElement = new Transition(xElement, yElement, radiusXElement, radiusYElement, 0);
            if (transitionsElement[q].getChildren("begin").length != 0) {
              elem.beginTr = transitionElement;
              elem.beginPl = null;
            }
            if (transitionsElement[q].getChildren("end").length != 0) {
              elem.endTr = transitionElement;
              elem.endPl = null;
            }
            transitionElement.id = idElement;
            transitionElement.name = nameElement;
            elem.transitions.add(transitionElement);
          } 
          catch (Exception e) {
            start = false;
            pressOk = false;
            errorMessage = "Error!\nDamaged file!";
          }
        }
      } 
      catch (Exception e) {
        start = false;
        pressOk = false;
        errorMessage = "Error!\nDamaged file!";
      }
      //load arcs
      XML[] arcsElement = elementNets[i].getChildren("arc");
      for (int q = 0; q < arcsElement.length; q++) {
        String idElement = arcsElement[q].getString("id");
        String sourceElement = arcsElement[q].getString("source");
        String targetElement = arcsElement[q].getString("target");
        String nameElement = arcsElement[q].getChildren("name")[0].getChildren("text")[0].getContent();
        String typeElement = arcsElement[q].getChildren("arctype")[0].getChildren("text")[0].getContent();
        Transition trElement = null;
        Place plElement = null;
        for (int j = 0; j < elem.places.size(); j++) {
          if (targetElement.equals(elem.places.get(j).id) || sourceElement.equals(elem.places.get(j).id)) {
            plElement = elem.places.get(j);
          }
        }
        for (int j = 0; j < elem.transitions.size(); j++) {
          if (targetElement.equals(elem.transitions.get(j).id) || sourceElement.equals(elem.transitions.get(j).id)) {
            trElement = elem.transitions.get(j);
          }
        }
        Arc arcElement = new Arc(plElement, trElement);
        arcElement.source = sourceElement;
        arcElement.target = targetElement;
        arcElement.name = nameElement;
        arcElement.id = idElement;
        arcElement.type = typeElement;
        elem.arcs.add(arcElement);
      }
      elem.shift();
    }
  } 
  catch (Exception e) {
    start = false;
    pressOk = false;
    errorMessage = "Error!\nDamaged file!";
  }
  mainMaxX = 0;
  mainMaxY = 0;
  mainMinX = net.transitions.get(0).transitionX;
  mainMinY = net.transitions.get(0).transitionY;
  for (int i = 0; i < net.transitions.size(); i++) {
    if (net.transitions.get(i).transitionX > mainMaxX) {
      mainMaxX = net.transitions.get(i).transitionX;
    }
    if (net.transitions.get(i).transitionY > mainMaxY) {
      mainMaxY = net.transitions.get(i).transitionY;
    }
    if (net.transitions.get(i).transitionX < mainMinX) {
      mainMinX = net.transitions.get(i).transitionX;
    }
    if (net.transitions.get(i).transitionY < mainMinY) {
      mainMinY = net.transitions.get(i).transitionY;
    }
  }
  for (int i = 0; i < net.places.size(); i++) {
    if (net.places.get(i).placeY > mainMaxY) {
      mainMaxY = net.places.get(i).placeY;
    }
    if (net.places.get(i).placeX > mainMaxX) {
      mainMaxX = net.places.get(i).placeX;
    }
    if (net.places.get(i).placeY < mainMinY) {
      mainMinY = net.places.get(i).placeY;
    }
    if (net.places.get(i).placeX < mainMinX) {
      mainMinX = net.places.get(i).placeX;
    }
  }
  mainMaxX = mainMaxX + mainMinX;
  mainMaxY = mainMaxY + mainMinY;
  scaledMainMaxX = mainMaxX;
  scaledMainMaxY = mainMaxY;
  net.scaleChanged(scaleOfNet);
  menu = new Menu();
}