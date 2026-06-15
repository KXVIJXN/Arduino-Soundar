A-RADAR

An Arduino-based ultrasonic radar that sweeps an HC-SR04 sensor across a servo arc and reports distance at each angle in real time over serial. Built from bare components, soldered, and programmed in embedded C.





Overview

KA-RADAR mounts an HC-SR04 ultrasonic distance sensor on a servo motor. The servo sweeps the sensor through an arc; at each step the firmware fires an ultrasonic ping, measures the echo return time, converts it to a distance, and streams the angle and distance over the serial port. The result is a low-cost, single-axis proximity scanner that behaves like a simplified radar.

The project was built end to end: component-level assembly, through-hole soldering, wiring, and firmware written in embedded C on the Arduino toolchain.

Hardware

ComponentDetailMicrocontrollerArduino UNO R3 (Elegoo)Distance sensorHC-SR04 ultrasonic ranging moduleActuatorMicro servo (e.g. SG90) WiringJumper leads and soldered connections on breadboard or protoboardPower5V via USB

Wiring

Update the pin column to match your build.

SignalArduino pinHC-SR04 VCC5VHC-SR04 GNDGNDHC-SR04 TRIG[your TRIG pin, e.g. D9]HC-SR04 ECHO[your ECHO pin, e.g. D10]Servo signal[your servo pin, e.g. D11]Servo VCC / GND5V / GND

The SG90 can draw current spikes that disturb a shared 5V rail. If readings glitch during servo motion, power the servo from a separate 5V supply with a common ground.

How it works


Trigger. The firmware sends a 10 us HIGH pulse on TRIG. The HC-SR04 emits an 8-cycle 40 kHz ultrasonic burst.
Echo timing. ECHO goes HIGH for the round-trip flight time of the burst. The firmware measures that pulse width with pulseIn().
Distance. Time of flight is converted to distance using the speed of sound: distance_cm = echo_us / 58, equivalent to echo_us x 0.0343 cm/us halved for the round trip at roughly 20 C.
Sweep. A servo steps the sensor across the arc [your range, e.g. 0 to 180 degrees] in [your step, e.g. 1 degree] increments, taking a reading at each angle.
Output. Each measurement is sent over serial as an angle,distance pair at [your baud, e.g. 9600] for logging or visualisation.


The loop runs continuously, sweeping out and back, producing a live stream of angle and distance data.

Signal processing


Keep this section only if you implemented smoothing. Otherwise delete it.



Raw HC-SR04 readings are noisy and occasionally drop out. To stabilise the output, each angle's distance is filtered using [your method, e.g. a median of 3 to 5 successive pings, or a moving average], and out-of-range returns are discarded rather than reported as false hits.

Repository structure

.
├── src/            # Arduino firmware (embedded C / .ino)
├── visualiser/     # optional: Processing sketch for the radar display
├── docs/           # optional: photos, wiring diagram, captures
└── README.md

Build and run


Open the firmware in the Arduino IDE.
Select Tools > Board > Arduino Uno and the correct serial port.
Upload.
Open Serial Monitor (or Serial Plotter) at the matching baud rate to see the live angle and distance stream.



If you built a Processing visualiser, run the sketch in visualiser/ with the same serial port and baud rate to render the sweep.



Skills demonstrated


Embedded C on the Arduino toolchain
Real-time sensor interfacing and time-of-flight measurement
Servo actuation with coordinated sensor and actuator timing
Converting raw sensor signals into usable measurements, with noise handling
Hardware bring-up: component-level assembly and through-hole soldering
Serial protocol for host communication and visualisation


Limitations


Single axis. The rig scans one plane only.
Sensor constraints. Roughly 2 cm to 400 cm range, a wide (~15 degree) beam that limits angular resolution, and a short blind zone at very close range.
No temperature compensation. The speed-of-sound constant assumes ~20 C, so accuracy drifts with ambient temperature.
Soft or oblique targets reflect poorly and can be missed.


Possible improvements


Median or Kalman filtering for cleaner returns
Temperature compensation for the speed-of-sound calculation
A second servo axis for 2D scanning
Oscilloscope or logic-analyser captures on the TRIG and ECHO lines to document timing
Porting the firmware to an STM32 / ARM Cortex-M target


Author

Kavijan Anantharasa
