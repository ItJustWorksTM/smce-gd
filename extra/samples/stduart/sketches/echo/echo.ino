void setup() {
    Serial.begin(9600);
}

void loop() {
    if(Serial.available())
        Serial.print(Serial.readString());

#ifdef __SMCE__
    delay(1); // Avoid overwhelming the CPU
#endif
}
