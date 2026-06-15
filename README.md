KA-RADAR (Arduino-Soundar)

An Arduino-based ultrasonic radar that sweeps an HC-SR04 sensor across a 180-degree servo arc, reports angle and distance in real time over serial, and drives a proximity alarm buzzer whose beep rate increases as a target closes. Built from components, soldered, and programmed in embedded C.

<img width="4284" height="4922" alt="IMG_3226" src="https://github.com/user-attachments/assets/a6da49b7-28e0-48f8-95db-c3c118815e03" />

Overview

The system mounts an HC-SR04 ultrasonic sensor on a micro servo. The servo sweeps 0 to 180 degrees in 1-degree steps; at each step the firmware fires a ranging ping, reads the distance, and streams the angle and distance over serial. A Processing visualiser on the host renders the sweep as a radar display.

If a target is detected within 40 cm, a buzzer activates. The beep interval is mapped to distance: the closer the target, the faster the beep. Below roughly 10 cm the beeping becomes near-continuous. Beyond 40 cm the buzzer is silenced.

The project was built end to end: component-level assembly, through-hole soldering, wiring, and firmware written in embedded C on the Arduino toolchain.

Hardware

| Component | Detail |
|---|---|
| Microcontroller | Arduino UNO R3 (Elegoo) |
| Distance sensor | HC-SR04 ultrasonic ranging module |
| Actuator | Micro servo (SG90 or equivalent) |
| Alarm | Passive buzzer |
| Wiring | Jumper leads and soldered connections |
| Power | 5V via USB |

Pin map

| Signal | Arduino pin |
|---|---|
| HC-SR04 TRIG | D12 |
| HC-SR04 ECHO | D11 |
| Servo signal | D9 |
| Buzzer | D8 |
| HC-SR04 VCC / GND | 5V / GND |
| Servo VCC / GND | 5V / GND |

Note: the SG90 can draw current spikes that disturb the shared 5V rail. If readings glitch during servo motion, power the servo from a separate 5V supply with a common ground.

## How it works

Ranging. The firmware uses the NewPing library to trigger the HC-SR04 and return distance directly in centimetres via `sonar.ping_cm()`. NewPing provides more reliable ultrasonic timing than the standard `pulseIn()` approach and handles timeout and out-of-range returns cleanly.

Sweep. A non-blocking `millis()` timer steps the servo one degree every 30 ms, sweeping 0 to 180 degrees and reversing at each limit. Each step triggers a ranging ping and sends the result over serial as `angle,distance.` at 9600 baud.

Proximity alarm. If the returned distance is between 1 and 39 cm, the buzzer activates. The beep interval is computed with `map(distance, 40, 0, 100, 10)`, mapping a 40 cm reading to a 100 ms interval and a 0 cm reading to a 10 ms interval. The buzzer toggles on a separate `millis()` timer so the sweep is never blocked waiting for a beep to finish. Readings of 0 cm (no echo within 200 cm) are treated as out-of-range and the buzzer is silenced.

Visualiser. A Processing sketch on the host reads the serial stream and renders the sweep as a radar display with distance arcs and target markers.

Repository structure

```
.
├── src.ino           # Arduino firmware
├── Visualiser.pde    # Processing radar display
└── README.md
```

Build and run

1. Install the NewPing library via the Arduino IDE Library Manager.
2. Open `src.ino`, select **Tools > Board > Arduino Uno** and the correct serial port.
3. Upload.
4. Open Serial Monitor at 9600 baud to see the raw `angle,distance` stream, or run `Visualiser.pde` in Processing with the same port and baud rate to render the radar display.

Skills demonstrated

- Embedded C on the Arduino toolchain
- Ultrasonic time-of-flight ranging with the NewPing library
- Non-blocking servo sweep using `millis()` timing
- Real-time distance-to-frequency mapping for a variable-rate proximity alarm
- Decoupled concurrent tasks: sweep, ranging, and buzzer toggle each run on independent `millis()` timers without blocking one another
- Serial protocol for host communication
- Host-side visualisation in Processing

Limitations

- Single axis. The rig scans one plane only.
- Sensor constraints. 2 cm to 200 cm range (configured), wide beam (~15 degrees) limiting angular resolution, short blind zone at very close range.
- No temperature compensation. The speed-of-sound constant assumes roughly 20 C.
- Soft or oblique targets reflect poorly and may be missed.

Possible improvements

- Median filtering across multiple pings per angle for cleaner returns
- Temperature compensation using a DS18B20 or DHT sensor
- Oscilloscope captures on TRIG and ECHO lines to document timing and validate sensor behaviour
- A second servo axis for 2D scanning
- Porting to STM32 / ARM Cortex-M for tighter timing control and lower-level peripheral access

Author

Kavijan Anantharasa
