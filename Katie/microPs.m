% FIR bandpass filter design for microPs project
% Ts = 0.05
% Tc1 = 0.1 Hz and Tc2 = 3.5 Hz

% Brick wall filter:
f = [0 0.1 0.1 0.3 0.3 1];
m = [0 0 1 1 0 0];

% FIR filter:
b = fir1(30,[0.01 0.35],'bandpass');
[h,w]=freqz(b,1,10000);
plot(f,m,w/pi,abs(h))