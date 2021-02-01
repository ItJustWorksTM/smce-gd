void setup() {
    pinMode(0, INPUT);
    pinMode(2, OUTPUT);
}

void loop() {
    digitalWrite(2, !digitalRead(0));
    delay(1);
}
