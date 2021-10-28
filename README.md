# Measuring-system-for-determining-the-quality-of-LED-light-sources
Development and manufacture of measuring system for determining the quality of LED light sources and overview of LED light bulbs for household use available on the Slovenian market

Modern LED light sources have many advantages as well as some disadvantages. One of them is a fluctuating luminous flux, which in some cases negatively affects people's health and well-being. The article describes the design and making process of a portable measuring system that allows performing multiple measurements to determine the quality of LED substitutes for conventional light bulbs. The measurement system is controlled using the MATLAB software environment, in which data processing and plotting of measurement results are also performed. Using developed measuring system, measurements were made of 59 LED bulbs of various types and manufacturers, which are available on the Slovenian market. The LED bulbs are classified based on two parameters: the percentage of fluctuations in the luminous flux and the deviation of the measured luminous flux compared to the value stated on the packaging.

MATLAB_Measuring_system_control_and_plotting_the_results.m
This is the main matlab code with which we:
 - control the measuring system (switch on/off the light bulb, rotate the sliding table with the light bulb, capture data),
 - set the data acquisition parameters,
 - plot the measurement results,
 - save the plots to the created folder.
