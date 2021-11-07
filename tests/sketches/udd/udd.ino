#include "TotallyOOP.hxx"

TotallyOOP oop{42};

void setup() {
    oop.read();
    oop.write(123);
    Serial.begin(9600);
}
void loop() {
    if (Serial.available()) {
        Serial.println(Serial.readString());
    }
}
