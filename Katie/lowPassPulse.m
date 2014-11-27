function  lowPassPulse( VoltIn, fs, fc )
% LOWPASSPULSE takes in a heartbeat signal and downsamples it to 20 Hz and
% lowpasses it with a cutoff frequency of fc.

fs2 = 200;
downfactor = fs/fs2;
VoltDown = downsample(VoltIn, downfactor);
hold off
[y,t] = lowPass(VoltDown, fs2, fc);
plot(t,VoltDown,'r')
hold on
plot(t,y)
hold off
end

