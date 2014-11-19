#include <P32xxxx.h>

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


void initadc(int channel) {
	AD1CHSbits.CHOSA = channel; // select which channel
	AD1PCFGCLR = 1 << channel; // configure input pin
	AD1CON1bits.ON = 1; // turn ADC on
	AD1CON1bits.SAMP = 1; // begin sampling
	AD1CON1bits.DONE = 0; // clear DONE flag
}

int readadc(void) {
	AD1CON1bits.SAMP = 0; // end sampling, start conversion
	while (!AD1CON1bits.DONE); // wait until DONE
	AD1CON1bits.SAMP = 1; // resume sampling
	AD1CON1bits.DONE = 0; // clear DONE flag
	return ADC1BUF0; // return result
}

int main(void) {
	int sample;
	initadc(11);
	sample = readadc();
}