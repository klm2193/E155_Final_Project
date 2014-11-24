Ts = 0.05;
w1 = 0.5*(2*pi*Ts/pi)
w2 = 3.5*(2*pi*Ts/pi)
Wn = [w2]%[w1 w2]
% b = butter(40, Wn, 'bandpass');
b = fir1(30, Wn);%, 'bandpass');
[h,w] = freqz(b,1,1000);

f = [0 w1 w1 w2 w2 1];
m = [0 0 1 1 0 0];

f = [0 w2 w2 1];
m = [1 1 0 0];

% f = [0 0.6 0.6 0.8 0.8 1];
% m = [0 0 1 1 0 0 ];
% b = fir2(30,f,m);
% [h,w] = freqz(b,1,128);

% plot(f, m, w/pi,abs(h))
plot(f,m,w/pi,abs(h))
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude')
legend('Ideal','fir1 designed')
% legend boxoff
title('Comparison of Frequency Response Magnitudes')
grid on