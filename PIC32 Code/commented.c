// Kaitlin Kimberling and Kristina Ming
// E155 Final Project: Non-Invasive Heart Rate Monitor

#include <P32xxxx.h>
#include <plib.h>

// function prototypes!
void initTimers(void);
void initspi(void);
int spi_send_receive(unsigned short send);
void initadc(int channel);
int readadc(void);
void playNote(unsigned short period, unsigned short duration);

// We want to sample at 200 Hz
// Divide clock by 4 (10 MHz clk) and have prescalar of 8

// initialize timers
void initTimers(void) {
	
	//	Assumes peripheral clock at 10MHz
	
	//	Use Timer3 for frequency generation	
	//	T3CON
	//	bit 15: ON = 1: enable timer
	//	bit 14: FRZ = 0: keep running in exception mode
	//	bit 13: SIDL = 0: keep running in idle mode
	//	bit 12-8: unused
	//	bit 7: 	TGATE = 0: disable gated accumulation
	//	bit 6-4: TCKPS = 011: 1:8 prescaler
	//	bit	3:	T32=0: 16-bit timer
	//	bit 2:	unused
	//	bit 1:	TCS = 0: use internal peripheral clock
	//	bit 0:	unused
	T3CON = 0b1000000000110000;
	
	// Timers for speaker
	
	// 	Use Timer1 for note duration
	//	T1CON
	//	bit 15: ON = 1: enable timer
	//	bit 14: FRZ = 0: keep running in exception mode
	//	bit 13: SIDL = 0: keep running in idle mode
	//	bit 12: TWDIS = 1: ignore writes until current write completes
	//	bit 11: TWIP = 0: don't care in synchronous mode
	//	bit 10-8: unused
	//	bit 7:	TGATE = 0: disable gated accumulation
	//	bit 6:	unused
	//	bit 5-4: TCKPS = 11: 1:256 prescaler
	//	bit 3:	unused
	//	bit 2:	don't care in internal clock mode
	// 	bit 1:	TCS = 0: use internal peripheral clock
	//	bit 0:	unused
	T1CON = 0b1001000000110000;

	//	Use Timer2 for frequency generation	
	//	T2CON
	//	bit 15: ON = 1: enable timer
	//	bit 14: FRZ = 0: keep running in exception mode
	//	bit 13: SIDL = 0: keep running in idle mode
	//	bit 12-8: unused
	//	bit 7: 	TGATE = 0: disable gated accumulation
	//	bit 6-4: TCKPS = 001: 1:2 prescaler
	//	bit	3:	T32 = 0: 16-bit timer
	//	bit 2:	unused
	//	bit 1:	TCS = 0: use internal peripheral clock
	//	bit 0:	unused
	T2CON = 0b1000000000010000;
}

// intialize SPI
void initspi(void) {
	int junk;

	SPI2CONbits.ON = 0; // disable SPI to reset any previous state
	junk = SPI2BUF; // read SPI buffer to clear the receive buffer
	SPI2BRG = 3; //set BAUD rate to 1.25MHz, with Pclk at 10MHz 
	SPI2CONbits.MSTEN = 1; // enable master mode
	SPI2CONbits.CKE = 1; // set clock-to-data timing (data centered on rising SCK edge) 
	SPI2CONbits.ON = 1; // turn SPI on
	SPI2CONbits.MODE16 = 1; // use 16-bit mode
}

// send and receive via SPI
int spi_send_receive(unsigned short send) {
	SPI2BUF = (send); // send data to slave
	while (!SPI2STATbits.SPIBUSY); // wait until received buffer fills, indicating data received 
	return SPI2BUF; // return received data and clear the read buffer full
}

// initialize ADC
void initadc(int channel) {
	AD1CHSbits.CH0SA = channel; // select which channel
	AD1PCFGCLR = 1 << channel; // configure input pin
	AD1CON1bits.ON = 1; // turn ADC on
	AD1CON1bits.SAMP = 1; // begin sampling
	AD1CON1bits.DONE = 0; // clear DONE flag
}

// read ADC
int readadc(void) {
	AD1CON1bits.SAMP = 0; // end sampling, start conversion
	while (!AD1CON1bits.DONE); // wait until DONE
	AD1CON1bits.SAMP = 1; // resume sampling
	AD1CON1bits.DONE = 0; // clear DONE flag
	return ADC1BUF0; // return result
}

// function to play a given note for a certain duration
void playNote(unsigned short period, unsigned short duration) {
	
	TMR1 = 0;	// Reset timers
	TMR2 = 0;
	
	while (TMR1 < duration) {	// Play until note ends
		if (period != 0) {		// Not a rest, so oscillate
			PORTDbits.RD9 = 0;	// Output low
			TMR2 = 0;
			while (TMR2 < period) {}	// wait
			PORTDbits.RD9 = 1;	// Output high
			TMR2 = 0;
			while (TMR2 < period) {}	// wait
		}
	}
}

int main(void) {
	TRISD = 0xF100;
	
	unsigned short ADCReadings[10000];
	int i = 0;
	
	// initialize timers and SPI
	initTimers();
	initspi();

	TMR3 = 0; // Reset timer
	int duration = 6250;
	unsigned short sample;
	unsigned short received;
	initadc(2); // use channel 2 (AN2 is RB2)

	while (1) {
		while(TMR3 < duration){
			// wait
		}
		
		sample = readadc();
		PORTD = sample;
		TMR3 = 0; // reset timer
		
		if (i < 10000) {	
			ADCReadings[i] = sample;
			i++;
		}

		// send data over SPI (offset the value so it will fall
		// within the 8 bits for the DAC)
		received = spi_send_receive(sample-300);

		if (PORTDbits.RD8 == 1) { // we received a pulse!
			playNote(527, 5);
		}
	}
}
