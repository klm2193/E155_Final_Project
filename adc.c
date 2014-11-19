#include <P32xxxx.h>
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