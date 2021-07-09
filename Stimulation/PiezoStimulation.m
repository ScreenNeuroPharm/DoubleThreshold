function [StimProtocol, SimulDurSample] = PiezoStimulation(fs, IstimAmpl,fstim, StimDur_ms, SilentPeriod,NumberOfCycles, NumHours, baseline_dur)

StimDur_s = StimDur_ms/1000;
SimulDurSample = length(1:1/fs:(60*60*NumHours));

fstimMax = fs - 100;
if fstim > fstimMax
    fstim = fstimMax;
end
t_up = [0:1/fs:StimDur_s];
I = IstimAmpl * sin(2 * pi * fstim * t_up);
StimProtocol = repmat([I,zeros(1,SilentPeriod*fs)]',NumberOfCycles);
StimProtocol =  StimProtocol(:,1);

StimProtocol = [zeros(baseline_dur * fs, 1);StimProtocol];

t = ([1:length(StimProtocol)]')/fs;

% plot(t,StimProtocol(:,1));