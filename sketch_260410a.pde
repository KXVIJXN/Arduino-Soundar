import processing.serial.*;
Serial myPort;
String rawData = "";
float distanceInPixels;
int angle;
int distance;
boolean showRedLine = false;
PFont myFont;

// store distance at every angle for shape mapping
float[] scanDistances = new float[181];
int[] scanAlphas = new int[181];

void setup()
{
  size(1080, 720);
  smooth();
  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.');
  myFont = createFont("Courier New", 14);
  textFont(myFont);
  background(0);

  for (int i = 0; i <= 180; i++)
  {
    scanDistances[i] = -1;
    scanAlphas[i] = 0;
  }
}

void draw()
{
  noStroke();
  fill(0, 14);
  rect(0, 0, width, height - 50);

  drawRadar();
  drawObjectOutline();
  drawSweepLine();

  fill(0);
  noStroke();
  rect(0, height - 50, width, 50);
  drawText();
}

void drawRadar()
{
  pushMatrix();
  translate(width / 2, height - 50);
  noFill();
  strokeWeight(1);

  int numberOfCircles = 5;
  float maxRadius = (width - 50) / 2.0;

  for (int i = 1; i <= numberOfCircles; i++)
  {
    float radius = maxRadius * (i / (float) numberOfCircles);
    stroke(0, 120, 0, 80);
    arc(0, 0, radius * 2, radius * 2, PI, TWO_PI);
  }

  stroke(0, 120, 0, 60);
  for (int a = 0; a <= 180; a += 30)
  {
    float x = maxRadius * cos(radians(a));
    float y = maxRadius * sin(radians(a));
    line(0, 0, -x, -y);
  }

  stroke(0, 200, 0, 150);
  strokeWeight(2);
  line(-maxRadius, 0, maxRadius, 0);

  popMatrix();
}

void drawSweepLine()
{
  pushMatrix();
  translate(width / 2, height - 50);

  float maxRadius = (width - 50) / 2.0;

  // glow trail
  for (int i = 0; i < 15; i++)
  {
    int trailAngle = angle - (sweepDir() * i);
    if (trailAngle < 0 || trailAngle > 180) continue;
    int alpha = (int) map(i, 0, 15, 60, 0);
    stroke(0, 255, 0, alpha);
    strokeWeight(1);
    float x = maxRadius * cos(radians(trailAngle));
    float y = maxRadius * sin(radians(trailAngle));
    line(0, 0, -x, -y);
  }

  // main sweep line
  stroke(0, 255, 0, 200);
  strokeWeight(2);
  float x = maxRadius * cos(radians(angle));
  float y = maxRadius * sin(radians(angle));
  line(0, 0, -x, -y);

  popMatrix();
}

int lastAngle = 0;
int sweepDir()
{
  int dir = (angle >= lastAngle) ? 1 : -1;
  lastAngle = angle;
  return dir;
}

void drawObjectOutline()
{
  pushMatrix();
  translate(width / 2, height - 50);

  float maxRadius = (width - 50) / 2.0;

  // draw connected shape outline where objects are detected
  // find groups of consecutive detected angles and connect them
  boolean inShape = false;
  float prevX = 0;
  float prevY = 0;

  for (int i = 0; i <= 180; i++)
  {
    if (scanAlphas[i] > 0 && scanDistances[i] > 0)
    {
      float r = scanDistances[i];
      float x = -r * cos(radians(i));
      float y = -r * sin(radians(i));

      // draw filled shape between radar center and object surface
      if (inShape)
      {
        // connecting line between adjacent detected points
        stroke(255, 30, 30, scanAlphas[i]);
        strokeWeight(2);
        line(prevX, prevY, x, y);

        // filled area between the two points and center
        noStroke();
        fill(255, 0, 0, scanAlphas[i] / 6);
        triangle(0, 0, prevX, prevY, x, y);
      }

      // point on the surface
      noStroke();
      fill(255, 40, 40, scanAlphas[i]);
      ellipse(x, y, 6, 6);

      prevX = x;
      prevY = y;
      inShape = true;

      // fade
      scanAlphas[i] -= 1;
      if (scanAlphas[i] < 0) scanAlphas[i] = 0;
    }
    else
    {
      inShape = false;
    }
  }

  popMatrix();
}

void drawText()
{
  pushStyle();
  textFont(myFont);
  textSize(16);

  fill(0, 255, 0);
  text("KA-RADAR", 10, height - 18);

  if (!showRedLine)
  {
    fill(0, 200, 0);
    text("NO CONTACT", width / 4, height - 18);
  }
  else
  {
    fill(255, 50, 50);
    text("CONTACT", width / 4, height - 18);
    text("ANG: " + angle + "\u00B0", width / 2, height - 18);
    text("DST: " + distance + "cm", 3 * width / 4, height - 18);
  }

  fill(0, 200, 0, 150);
  text("SWEEP: " + angle + "\u00B0", width - 150, height - 18);

  popStyle();
}

void serialEvent(Serial myport)
{
  rawData = myport.readStringUntil('.');
  if (rawData != null)
  {
    rawData = rawData.substring(0, rawData.length() - 1);
    rawData = rawData.trim();
    int commaIndex = rawData.indexOf(',');
    if (commaIndex != -1)
    {
      String angleFromRawData = rawData.substring(0, commaIndex);
      String distanceFromData = rawData.substring(commaIndex + 1);
      angle = int(angleFromRawData);
      distance = int(distanceFromData);

      float maxRadius = (width - 50) / 2.0;

      if (distance > 0 && distance < 40)
      {
        showRedLine = true;
        distanceInPixels = map(distance, 0, 40, 0, maxRadius);

        if (angle >= 0 && angle <= 180)
        {
          scanDistances[angle] = distanceInPixels;
          scanAlphas[angle] = 255;
        }
      }
      else
      {
        showRedLine = false;
      }
    }
  }
}
