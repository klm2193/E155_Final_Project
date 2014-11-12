	Readme File for Code Example:
--------------------------------------------------

PIC32_ADC10\adc10_basic

--------------------------------------------------
Code Example Description:
--------------------------------------------------
The purpose of this example code is to demonstrate the PIC32MX peripheral library macros and functions supporting the ADC10 module and its various features.

In this example two channels are alternately sampled (the pot and temperature sensor) with the ADC operating in Alternate AutoSample mode. The most current results 
can be read from the pot and tempSensor variables.

--------------------------------------------------
Suggested Development Resources:
--------------------------------------------------
Explorer-16 demo board with 

Processors:	PIC32MX###F512L
		       360
		       460
		       795
		PIC32MX430F064L 
		PIC32MX450F256L 
		PIC32MX470F512L
            	PIC32MX220F032D (Temperature sensor and potentiometer must be soldered to the PIM)
		PIC32MX250F128D (Temperature sensor and potentiometer must be soldered to the PIM)
		

Complier:	MPLAB C32 v1 or higher
		MPLAB XC32 

IDE:		MPLAB IDE v8 or higher
            	MPLAB X IDE

--------------------------------------------------
Notes:
--------------------------------------------------
PIC32MX 2xx PIMS are unconnected to the potentiometer and temperature sensor on the Explorer-16. The soldering instructions that must 
be followed for proper functionality are stated below.

--------------------------------------------------
Soldering Instructions for PIC32MX 220/250 PIMS:
--------------------------------------------------
The test points (TP) are located on top of the PIM and must be connected to the temperature sensor and potentiometer on the Explorer-16 as follows:

Temperature sensor: TP23 (on the pim) to Pin 21 (on the Explorer-16)
Potentiometer: TP21 (on the pim) to Pin 20 (on the Explorer-16)


