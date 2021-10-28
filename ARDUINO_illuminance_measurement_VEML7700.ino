#include "Adafruit_VEML7700.h"    //included library for sensor VEML7700  
Adafruit_VEML7700 veml = Adafruit_VEML7700();

int lux;     //the variable "lux" intended to store the captured values

void setup() {
  while (!Serial) { delay(10);}    //opens a serial connection
  Serial.begin(9600);
  if (!veml.begin()) {
    while (1);
  }
  veml.setGain(VEML7700_GAIN_1);
  veml.setIntegrationTime(VEML7700_IT_800MS);

  switch (veml.getGain())
  {
    case VEML7700_GAIN_1:  break;
    case VEML7700_GAIN_2:  break;
    case VEML7700_GAIN_1_4:  break;
    case VEML7700_GAIN_1_8:  break;
  }
  switch (veml.getIntegrationTime())
  {
    case VEML7700_IT_25MS:  break; 
    case VEML7700_IT_50MS:  break;
    case VEML7700_IT_100MS:  break;
    case VEML7700_IT_200MS:  break;
    case VEML7700_IT_400MS:  break;
    case VEML7700_IT_800MS:  break;
  }
  veml.setLowThreshold(10000);
  veml.setHighThreshold(20000);
  veml.interruptEnable(true);
}

void loop() {
  lux = veml.readLux();   //reading the measured value from the sensor [lx]
  Serial.println(lux);    //print the current value to the serial output
  delay(10);             //delay - the measurement is performed every 0.1 second
}
