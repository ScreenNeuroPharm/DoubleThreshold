function [IstimExc, IstimInh] = Inoise(IstimDistribExc, IstimDistribInh)
% This function gives a random chosen value extracted from a Gaussian
% distribution.
% 
%                   Paolo Massobrio - last update 18th May 2016

valueExc = randi(length(IstimDistribExc), 1, 1);  % genero un valore da prendere da IstimExc
valueInh = randi(length(IstimDistribInh), 1, 1);  % genero un valore da prendere da IstimInh

IstimExc = IstimDistribExc(valueExc);
IstimInh = IstimDistribInh(valueInh);

