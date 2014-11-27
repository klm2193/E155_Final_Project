function [ filtered ] = ImplementFIR( VoltIn, fs )
%IMPLEMENTFIR will calculate the FIR filter coefficients and convolve with
% the input signal to filter it.

fsdown = 200;
VoltDown = downsample(VoltIn,fs/fsdown);
len = length(VoltDown);
t = 0:1/fsdown:len/fsdown;
b = fir1(30,0.35);
filtered = conv(VoltIn,b);
hold off
plot(t(1:len),filtered(1:len))

end

