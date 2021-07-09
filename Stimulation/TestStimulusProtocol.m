function [StimProtocol, SimulDurSample] = TestStimulusProtocol(fs, IstimAmpl,StimDur_ms, Period_ms, NumberOfCycles, NumHours)
% This function implements an ad hoc version of the commonly used test
% stimulus protocol.
% 
%           Paolo Massobrio - last update 20th October 2016
% 
% 
SimulDurSample = length(1:1/fs:(60*60*NumHours));
StimDur_samples = StimDur_ms * fs * 1e-3;
Period_samples = Period_ms * fs * 1e-3;
StimProtocol_temp = repmat([IstimAmpl * ones(StimDur_samples,1); zeros(Period_samples,1)],NumberOfCycles);
StimProtocol_temp2 = reshape(StimProtocol_temp, size(StimProtocol_temp,1)*size(StimProtocol_temp,2), 1);
StimProtocol = [StimProtocol_temp2; zeros(SimulDurSample - length(StimProtocol_temp2),1)];


