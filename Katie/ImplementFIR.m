function [ filtered ] = ImplementFIR( VoltIn, fs )
%IMPLEMENTFIR will calculate the FIR filter coefficients and convolve with
% the input signal to filter it.

tin = 0:1/fs:(length(VoltIn)-1)/fs;
fc = 3;
fsdown = 200;
ts = 1/fsdown;
VoltDown = downsample(VoltIn,fs/fsdown);
len = length(VoltDown);
t = 0:1/fsdown:len/fsdown;
b = fir1(30,fc*2*pi*ts);
filtered = conv(VoltIn,b);
hold off
plot(tin,VoltIn,'r')
hold on
plot(t,filtered(15:len+15),'b')
hold off

end

