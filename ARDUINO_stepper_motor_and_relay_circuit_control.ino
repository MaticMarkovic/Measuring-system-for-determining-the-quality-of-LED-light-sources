int Matlab_command = 0;   //variable intended to store a command from Matlab
int end_switch = 10;      //digital pin 10, end switch condition detection
int Stepper_enable = 12;
byte direction_rotation = 8;  //digital pin 8, determining the direction of motor rotation
byte motor_step = 9;      //digital pin 9, stepper motor control

void setup()
{
  Serial.begin(9600);
  pinMode(end_switch, INPUT);   //D10 - input
  pinMode(direction_rotation, OUTPUT);    //D8 - output
  pinMode(motor_step, OUTPUT);   //D9 - output
  pinMode(mosfet_gate, OUTPUT);
  pinMode(Stepper_enable, OUTPUT);
}

void loop()
{
  if (Serial.available () > 0)
  {
    Matlab_command = Serial.read();   //read command on serial input, save to Matlab_command
    Serial.println(Matlab_command);      //print the value of Matlab_command

    switch (Matlab_command) //switch loop, value from Matlab
    {
      //command from Matlab is 1, the sliding table of the measuring system moves to the starting position 0°
      case 1:
        digitalWrite(direction_rotation, LOW);
        for (int n = 0; (digitalRead(end_switch) == LOW); n++)
        {
          digitalWrite(motor_step, HIGH);
          digitalWrite(motor_step, LOW);
          delay(17);
        }
        digitalWrite(direction_rotation, HIGH);
        for (int n = 0; n < 50; n++)
        {
          digitalWrite(motor_step, HIGH);
          digitalWrite(motor_step, LOW);
          delay(17);
        }
        break;

      //command from Matlab is 2, perform a rotation of the sliding table by 3.6°
      case 2:
        digitalWrite(direction_rotation, HIGH);
        for (int n = 0; n < 2; n++)
        {
          digitalWrite(motor_step, HIGH);
          digitalWrite(motor_step, LOW);
          delay(17);
        }
        break;

      //command from Matlab is 3, turn ON the light bulb
      case 3:
        digitalWrite(mosfet_gate, HIGH);
        break;

      //command from Matlab is 4, turn OFF the light bulb
      case 4:
        digitalWrite(mosfet_gate, LOW);
        break;

      //command from Matlab is 5, enable stepper motor
      case 5:
        digitalWrite(Stepper_enable, HIGH);
        break;

      //command from Matlab is 6, disable stepper motor
      case 6:
        digitalWrite(Stepper_enable, LOW);
        break;
    }
  }
}
