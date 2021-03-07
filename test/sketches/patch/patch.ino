extern int foobar();

void setup() {
    pinMode(0, OUTPUT);
    analogWrite(0, foobar());
}

void loop() {
    delay(1);
}
