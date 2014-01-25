/* Author: Rodrigo Chamun */
import java.util.Stack;

static final int SIZE = 700;
static final int MAX_IT = 255;

boolean refresh = true;
boolean loading = true;
boolean drawSelection = false;
Stack<Rectangle> zoom = new Stack<Rectangle>();

PGraphics pg;
PVector pivot;

void setup() {
  size(SIZE,SIZE);
  pg = createGraphics(SIZE, SIZE);
  zoom.push(new Rectangle(-3, -2, 4, 4));
  background(0);
}

void draw() {
  if (loading) {
    refresh = true;
    loading = false;
    fill(255);
    textSize(32);
    text("Loading...", 10, 10, SIZE / 2, SIZE / 2);    
    return;
  }
  
  if (refresh)
    calculate();
  
  image(pg, 0, 0);
  
  if (drawSelection) {
    float w = (mouseX - pivot.x);
    float h = (mouseY - pivot.y);
    noFill();
    stroke(255);
    rect(pivot.x, pivot.y, w, h);
  }  
}

void mousePressed() {
  pivot = new PVector(mouseX, mouseY);
  drawSelection = true;
}

void mouseReleased() {
  Complex c1 = screen2Complex(min(mouseX, pivot.x), min(mouseY, pivot.y));
  Complex c2 = screen2Complex(max(mouseX, pivot.x), max(mouseY, pivot.y));
  if (!c1.equals(c2)) {
    zoom.push(zoomIn(c1.r, c1.i, c2.r - c1.r, c2.i - c1.i));
    loading = true;
  }
  drawSelection = false;
}

void mouseClicked() { 
  if (zoom.size() > 1) {
    zoom.pop();
    loading = true;
  } 
  
}

Rectangle zoomIn(float x, float y, float w, float h) {
  float nx, ny, nw, nh;
  if (w > h) {
    nx = x;
    nw = nh = w;
    ny = y - (w - h) / 2;
  } else {
    ny = y;
    nw = nh = h;
    nx = x - (h - w) / 2;
  }
  return new Rectangle(nx, ny, nw, nh);
}

void calculate() {
  pg.beginDraw();
  pg.background(255);
  for(int i = 0; i < SIZE; i ++)
    for (int j = 0; j < SIZE; j++) {
      int c = mandelbrot(screen2Complex(i, j));
      pg.stroke(c);
      pg.point(i, j);
    }
  pg.endDraw();
  refresh = false; 
}

Complex screen2Complex(float x, float y) {
  Rectangle viewport = zoom.peek();
  float r = (x / SIZE) * (viewport.getXw() - viewport.x) + viewport.x;
  float i = (y / SIZE) * (viewport.getYh() - viewport.y) + viewport.y;
  return new Complex(r, i);
}

int mandelbrot(Complex c) {
  Complex z = new Complex(0, 0);
  int it = 0;
  while (it < MAX_IT) {
    z.square();
    z.sum(c);
    if (z.magSq() > 4)
      break;
    it++;
  }
  return it == MAX_IT ? 0 : it;
}

class Rectangle {
  float x, y, w, h;
  
  Rectangle(float x, float y, float w, float h) { set(x, y, w, h); }
  
  float getXw() { return x + w; }
  float getYh() { return y + h; }
  
  void set(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

class Complex {
  float r;
  float i;
  
  Complex(float r, float i) {
    this.r = r;
    this.i = i;
  }
  
  void square() {
    float rr = r;
    float ii = i;
    r = rr * rr - ii * ii;
    i = 2 * rr * ii;
  }
  
  void sum(Complex c) {
    r += c.r;
    i += c.i;
  }
  
  float magSq() { return r * r + i * i; }
  
  boolean equals(Complex c) { return r == c.r && i == c.i; }
  
}
