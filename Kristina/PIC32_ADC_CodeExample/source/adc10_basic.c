/*********************************************************************
 *
 *     PIC32MX ADC10 API Example
 *
 *********************************************************************
 * FileName:        adc10_basic.c
 * Dependencies:    plib.h
 *
 *
 * Processor:       PIC32MX
 *
 * Complier:        MPLAB C32
 *                  MPLAB IDE v8.0+
 * Company:         Microchip Technology Inc.
 *
 * Software License Agreement
 *
 * The software supplied herewith by Microchip Technology Incorporated
 * (the Company) for its PIC32 Microcontroller is intended
 * and supplied to you, the Companys customer, for use solely and
 * exclusively on Microchip PIC32 Microcontroller products.
 * The software is owned by the Company and/or its supplier, and is
 * protected under applicable copyright laws. All rights are reserved.
 * Any use in violation of the foregoing restrictions may subject the
 * user to criminal sanctions under applicable laws, as well as to
 * civil liability for the breach of the terms and conditions of this
 * license.
 *
 * THIS SOFTWARE IS PROVIDED IN AN AS IS CONDITION. NO WARRANTIES,
 * WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
 * TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
 * IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
 * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 ******************************************************************
 * The purpose of this example code is to demonstrate the PIC32MX
 * peripheral library macros and functions supporting the ADC10
 * module and its various features.
 *
 * Platform: Explorer-16 with PIC32MX PIM
 *
 * Features demonstrated:
 *    - ADC setup and configuration using the peripheral library
 *    - Reading a potentiometer and temperature sensor with the
 *      ADC10 module
 *
 * Description: 
 *      In this example two channels are alternately sampled (the pot
 *      and temperature sensor) with the ADC operating in Alternate 
 *      AutoSample mode. The most current results can be read from the
 *      pot and tempSensor variables.
 * 
 * Notes:
 *    - PIC32MX 2xx PIMS are unconnected to the potentiometer and
 *      temperature sensor on the Explorer-16. The README states the
 *      soldering instructions that must be followed for proper
 *      functionality in this code example.
 ********************************************************************/
#include <plib.h>

#if defined (__32MX360F512L__) || (__32MX460F512L__) || (__32MX795F512L__) || (__32MX430F064L__) || (__32MX450F256L__) || (__32MX470F512L__)
// Configuration Bit settings
// SYSCLK = 80 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 80 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
// Other options are don't care
#pragma config FPLLMUL = MUL_20, FPLLIDIV = DIV_2, FPLLODIV = DIV_1, FWDTEN = OFF
#pragma config POSCMOD = HS, FNOSC = PRIPLL, FPBDIV = DIV_1
#define SYS_FREQ (80000000L)

#elif defined (__32MX220F032D__) || (__32MX250F128D__)
// Configuration Bit settings
// SYSCLK = 48 MHz (8MHz Crystal / FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 48 MHz (SYSCLK / FPBDIV)
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
// WDT OFF
// Other options are don't care
#pragma config FPLLMUL = MUL_24, FPLLIDIV = DIV_2, FPLLODIV = DIV_2, FWDTEN = OFF
#pragma config POSCMOD = HS, FNOSC = PRIPLL, FPBDIV = DIV_1
#define SYS_FREQ (48000000L)
#endif

// Define setup parameters for OpenADC10 function
// Turn module on | Ouput in integer format | Trigger mode auto | Enable autosample
#define config1     ADC_FORMAT_INTG | ADC_CLK_AUTO | ADC_AUTO_SAMPLING_ON
// ADC ref external | Disable offset test | Disable scan mode | Perform 2 samples | Use dual buffers | Use alternate mode
#define config2     ADC_VREF_AVDD_AVSS | ADC_OFFSET_CAL_DISABLE | ADC_SCAN_OFF | ADC_SAMPLES_PER_INT_2 | ADC_ALT_BUF_ON | ADC_ALT_INPUT_ON
// Use ADC internal clock | Set sample time
#define config3     ADC_CONV_CLK_INTERNAL_RC | ADC_SAMPLE_TIME_15
// Do not assign channels to scan
#define configscan  SKIP_SCAN_ALL

#if defined (__32MX460F512L__) || (__32MX795F512L__) || (__32MX430F064L__) || (__32MX450F256L__) || (__32MX470F512L__) || (__32MX220F032D__) || (__32MX250F128D__)
// AN4 = Temperature Sensor, AN2 = POT
#define configport  ENABLE_AN4_ANA | ENABLE_AN2_ANA
#elif defined (__32MX360F512L__)
// AN4 = Temperature Sensor, AN5 = POT
#define configport  ENABLE_AN4_ANA | ENABLE_AN5_ANA
#endif

unsigned int tempSensor;    // Connected to AN4
unsigned int pot;   // Connected to AN2 or AN5 (depending on device)
unsigned int offset;	// Buffer offset to point to the base of the idle buffer

int main(void)
{
    // Configure the device for maximum performance but do not change the PBDIV
    // Given the options, this function will change the flash wait states and
    // enable prefetch cache but will not change the PBDIV. The PBDIV value
    // is already set via the pragma FPBDIV option above..
    SYSTEMConfig(SYS_FREQ, SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);

    CloseADC10();   // Ensure the ADC is off before setting the configuration

    #if defined (__32MX460F512L__) || (__32MX795F512L__) || (__32MX430F064L__) || (__32MX450F256L__) || (__32MX470F512L__) || (__32MX220F032D__) || (__32MX250F128D__)
    // Configure to sample AN4 & AN2
    // Use ground as neg ref for A | use AN4 for input A | use ground as neg ref for A | use AN2 for input B
    SetChanADC10( ADC_CH0_NEG_SAMPLEA_NVREF | ADC_CH0_POS_SAMPLEA_AN4 |  ADC_CH0_NEG_SAMPLEB_NVREF | ADC_CH0_POS_SAMPLEB_AN2);
    #elif defined (__32MX360F512L__)
    // Configure to sample AN4 & AN5
    // Use ground as neg ref for A | use AN4 for input A | use ground as neg ref for A | use AN5 for input B
    SetChanADC10( ADC_CH0_NEG_SAMPLEA_NVREF | ADC_CH0_POS_SAMPLEA_AN4 |  ADC_CH0_NEG_SAMPLEB_NVREF | ADC_CH0_POS_SAMPLEB_AN5);
    #endif

    // Configure ADC using the parameters defined above
    OpenADC10( config1, config2, config3, configport, configscan );

    EnableADC10(); // Enable the ADC

    while (1)
    {
        while ( !mAD1GetIntFlag() )
        {
            // Wait for the first conversion to complete so there will be vaild data in ADC result registers
        }

        // Determine which buffer is idle and create an offset
        offset = 8 * ((~ReadActiveBufferADC10() & 0x01));

        // Read the result of temperature sensor conversion from the idle buffer
        tempSensor = ReadADC10(offset);

        // Read the result of pot conversion from the idle buffer
        pot = ReadADC10(offset + 1);

        mAD1ClearIntFlag();
    }
        
    while(1);
}


