Ts = 0.01;
Wn = [1*(2*pi*Ts/pi) 3*(2*pi*Ts/pi)];
b = fir1(40, Wn, 'bandpass');
[h,w] = freqz(b,1,1000);

% f = [0 0.6 0.6 0.8 0.8 1];
% m = [0 0 1 1 0 0 ];
% b = fir2(30,f,m);
% [h,w] = freqz(b,1,128);

% plot(f, m, w/pi,abs(h))
plot(w/pi,abs(h))
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude')
% legend('Ideal','fir2 designed')
% legend boxoff
title('Comparison of Frequency Response Magnitudes')
grid on