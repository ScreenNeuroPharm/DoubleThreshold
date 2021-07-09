function [s] = SynWeigthSF(SynWeightDistrib, NumMaxSynPerNeuron, NumSynPerNeuron, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[s] = SynWeigthDistributions(SynWeightDistrib, NumMaxSynPerNeuron, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh);    % This function creates a (NumNeur x M) connectivity matrix
% removing synaptic connections that do not exist
for i = 1:length(s)
    if NumSynPerNeuron(i) <= size(s,2)
        s(i,NumSynPerNeuron(i)+1:end) = 0;
    end
end
