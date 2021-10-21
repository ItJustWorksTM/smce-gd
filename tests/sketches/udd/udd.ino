#include "TotallyOOP.hxx"

TotallyOOP oop{42};

void setup() {
    oop.read();
    oop.write(123);
}
void loop() {
	Serial.println("invalid!");
}
