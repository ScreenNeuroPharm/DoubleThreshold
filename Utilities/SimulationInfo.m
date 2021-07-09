function [SimInfo] = SimulationInfo(NumHours, fs, NumNeur, FracExc, M, D, sm, w_E0, w_I0, tau_stdp, IstimExc_avg,IstimExc_std, IstimInh_avg,IstimInh_std)
% This function stores in a cell array the most important and significant
% features of the model and simulation
% 
%                Last update 18th May 2016   Paolo Massobrio

SimInfo = cell(14,1);
if NumHours >=1
    SimInfo{1,1}= struct('SimDur',NumHours);        % expressed in hours
else
    SimInfo{1,1}= struct('SimDur',NumHours*60);     % expressed in minutes
end
SimInfo{2,1}= struct('SamplingFreq',fs);
SimInfo{3,1}= struct('NumNeur',NumNeur);
SimInfo{4,1}= struct('PercentageExcitatoryNeurons',FracExc);
SimInfo{5,1}= struct('MaxSynapticDelay_ms',D);
SimInfo{6,1}= struct('MaxSynapticWeigth',sm);
SimInfo{7,1}= struct('MaxDegreePerNeuron',M);
SimInfo{8,1}= struct('InitialExcitatoryWeigths',w_E0);
SimInfo{9,1}= struct('InitialInhibitoryWeigths',w_I0);
SimInfo{10,1}= struct('TimeConstantSTDP_ms',tau_stdp);
SimInfo{11,1}= struct('MeanBackgroundCorrentExc',IstimExc_avg);
SimInfo{12,1}= struct('StdBackgroundCorrentExc',IstimExc_std);
SimInfo{13,1}= struct('MeanBackgroundCorrentInh',IstimInh_avg);
SimInfo{14,1}= struct('StdBackgroundCorrentInh',IstimInh_std);
