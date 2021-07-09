function [bins, n_norm, max_y] = f_single_IBIh_Model(ibis, fc, max_x, binsec)
% Computes the Inter-Burst Interval Histograms of the input ibis

% max_x = maximum value of IBI considered [s]
% fc = sampling frequency [Hz]
% binsec = bin size (sec)

warning off all

bins = (binsec/2):binsec:max_x;     % IBI bins
Nbins = length(bins);                   % Number of bins

if ~isempty(ibis)    
    IBI_to_plot = ibis(find(ibis <= max_x));  % ISI <= max ISI visualized
    [n] = hist(IBI_to_plot,bins);
    n_norm = n/sum(n); % ISI histogram normalized
    
    max_IBI = max(ibis);
    max_y = max(n_norm);    
else    
    n_norm = zeros(1,Nbins);    
    max_IBI = NaN;
    max_y = NaN;    
end