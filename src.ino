#include <Servo.h>
#include <NewPing.h>

const int buzzerPin = 8;
const int servoPin = 9;
const int triggerPin = 12;
const int echoPin = 11;
const int maxDistance = 200;

Servo myservo;
NewPing sonar(triggerPin, echoPin, maxDistance);

int currentAngle = 0;
int sweepDirection = 1;
unsigned long lastStepTime = 0;
const int stepDelay = 30;

unsigned long lastBuzzerToggle = 0;
int buzzerInterval = 0;
bool buzzerOn = false;
bool buzzerActive = false;

void setup()
{
  pinMode(buzzerPin, OUTPUT);
  myservo.attach(servoPin);
  Serial.begin(9600);
  myservo.write(0);
  delay(500);
}

void loop()
{
  unsigned long now = millis();

  if (now - lastStepTime >= stepDelay)
  {
    lastStepTime = now;
    myservo.write(currentAngle);
    long distance = sonar.ping_cm();

    Serial.print(currentAngle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");

    if (distance > 0 && distance < 40)
    {
      buzzerActive = true;
      buzzerInterval = map(distance, 40, 0, 100, 10);
    }
    else
    {
      buzzerActive = false;
      digitalWrite(buzzerPin, LOW);
      buzzerOn = false;
    }

    currentAngle += sweepDirection;
    if (currentAngle >= 180)
    {
      currentAngle = 180;
      sweepDirection = -1;
    }
    else if (currentAngle <= 0)
    {
      currentAngle = 0;
      sweepDirection = 1;
    }
  }

  if (buzzerActive && millis() - lastBuzzerToggle >= (unsigned long)buzzerInterval)
  {
    lastBuzzerToggle = millis();
    buzzerOn = !buzzerOn;
    digitalWrite(buzzerPin, buzzerOn ? HIGH : LOW);
  }
}
