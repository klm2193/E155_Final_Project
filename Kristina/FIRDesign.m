f = [0 0.6 0.6 1];
m = [1 1 0 0];
b = fir2(30,f,m);
[h,w] = freqz(b,1,128);

plot(f,m,w/pi,abs(h))
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude')
legend('Ideal','fir2 designed')
legend boxoff
title('Comparison of Frequency Response Magnitudes')