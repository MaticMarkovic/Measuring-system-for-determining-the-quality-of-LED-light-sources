# Measuring-system-for-determining-the-quality-of-LED-light-sources

Modern LED light sources have many advantages as well as some disadvantages. One of them is a fluctuating luminous flux, which in some cases negatively affects people's health and well-being. The article describes the design and making process of a portable measuring system that allows performing multiple measurements to determine the quality of LED substitutes for conventional light bulbs. The measurement system is controlled using the MATLAB software environment, in which data processing and plotting of measurement results are also performed. Using developed measuring system, measurements were made of 59 LED bulbs of various types and manufacturers, which are available on the Slovenian market. The LED bulbs are classified based on two parameters: the percentage of fluctuations in the luminous flux and the deviation of the measured luminous flux compared to the value stated on the packaging.

MATLAB_Measuring_system_control_and_plotting_the_results.m
-
This is the main MATLAB code with which we:
 - control the measuring system (switch on/off the light bulb, rotate the sliding table with the light bulb, capture data),
 - set the data acquisition parameters,
 - plot the measurement results,
 - save the plots to the created folder.

MATLAB_Light_bulbs_clasification_program___deviation_of_luminous_flux.m
-
Using this program, the LED light bulbs are clasified in the table based on the parameter: the deviation of the measured luminous flux compared to the value stated on the packaging - starting with the light bulb with the lowest value to the highest.

MATLAB_Light_bulbs_clasification_program___percentage_of_fluctuation.m
-
Using this program, the LED light bulbs are clasified in the table based on the parameter: the percentage of fluctuations in the luminous flux - starting with the light bulb with the lowest value to the highest.

ARDUINO_stepper_motor_and_relay_circuit_control.ino
-
The light bulb is switched on/off with the manufactured circuit. The Arduino UNO receives a command from the MATLAB and gives the voltage on the gate pin of the mosfet. Mosfet enable/disable the flow of electric current through the relay's winding and switches the light bulb on/off.

ARDUINO_illuminance_measurement_VEML7700.ino
-
The measuring system uses a sensor of illuminance manufactured by Adafruit with the designation VEML7700. Sensor is connected to Microcontroler Arduino UNO using I2C communication protocol.
