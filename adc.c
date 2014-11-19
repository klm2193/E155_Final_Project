#include <P32xxxx.h>

// function prototypes!
void initTimers(void);
void initspi(void);
int spi_send_receive(signed short sendX, signed short sendY);
void initadc(int channel);
int readadc(void) ;

// initialize timers
void initTimers(void) {
	
	//	Assumes peripheral clock at 5MHz

	//	Use Timer3 for frequency generation	
	//	T3CON
	//	bit 15: ON=1: enable timer
	//	bit 14: FRZ=0: keep running in exception mode
	//	bit 13: SIDL = 0: keep running in idle mode
	//	bit 12-8: unused
	//	bit 7: 	TGATE=0: disable gated accumulation
	//	bit 6-4: TCKPS=110: 1:64 prescaler
	//	bit	3:	T32=0: 16-bit timer
	//	bit 2:	unused
	//	bit 1:	TCS=0: use internal peripheral clock
	//	bit 0:	unused
	T3CON = 0b1000000001100000;
}

// intialize SPI
void initspi(void) {
	signed short junk;

	SPI2CONbits.ON = 0; // disable SPI to reset any previous state
	junk = SPI2BUF; // read SPI buffer to clear the receive buffer
	SPI2BRG = 7; //set BAUD rate to 1.25MHz, with Pclk at 20MHz 
	SPI2CONbits.MSTEN = 1; // enable master mode
	SPI2CONbits.CKE = 1; // set clock-to-data timing (data centered on rising SCK edge) 
	SPI2CONbits.ON = 1; // turn SPI on
	SPI2CONbits.MODE32 = 1;
}

// send and receive via SPI
int spi_send_receive(signed short sendX, signed short sendY) {
	SPI2BUF = ((sendX << 16) | (sendY & 0xFFFF)); // send data to slave
	while (!SPI2STATbits.SPIBUSY); // wait until received buffer fills, indicating data received 
	return SPI2BUF; // return received data and clear the read buffer full
}

// initialize ADC
void initadc(int channel) {
	AD1CHSbits.CHOSA = channel; // select which channel
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

int main(void) {
	initTimers();
	TMR3 = 0; // Reset timer
	int duration = 4;
	int sample;
	initadc(11);
	while(TMR3 < duration){
		sample = readadc();
		TMR3 = 0; // Reset timer
		// Then do SPI stuff ??
	}
}