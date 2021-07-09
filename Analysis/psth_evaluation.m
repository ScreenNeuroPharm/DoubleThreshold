function [psth_count, psth_count_non_norm, latency, FullStimWin]= psth_evaluation (peak_train, artifact, fs, bin, cancw, psthend)
% psth.m
% Function for calculating the PSTH with parameters defined by the user
% INPUT VARIABLES          
%           peak_train  = train of spikes with spike amplitude [sparse array]
%           artifact    = train with artifact position
%           fs          = sampling frequency [samples/sec]
%           bin         = PSTH bin - def by user [msec]
%           cancw       = deleting artifact window - def by user [msec]
%           psthend     = time length of the histogram [msec]
% OUTPUT VARIABLES
%           psth_count  = post-stimulus histogram array [number of spikes]
%           latency     = latency from stimulus for the first evoked spike [msec]
%           FullStimWin = array with all spikes within a post-stimulus window
% by Michela Chiappalone (18-19 gennaio 2006)

% ----------> DEFINE LOCAL VARIABLES
binsample= bin*fs/1000;             % bin size [samples]
cancsample= cancw*fs/1000;          % canc window size [samples]
psthendsample=psthend*fs/1000;      % time length of the histogram [samples]
n= length(artifact);                % number of artifact
psth_count= zeros((psthend/bin),1); % psthend/bin = total number of bin for the histogram
latency_el= zeros(n,1);             % latencies for current channel
latency= zeros(1,3);                % latency(mean, sd, se) for current channel
FullStimWin=zeros(n,psthendsample); % array with all the post-stimulus windows

% ----------> START PROCESSING
if (n>=1)                                                              % number of artifact must be at least 1
    for k=1:n                                                          % cycle over stimuli
        % Post Stimulus Histogram construction
        if (k==n)&(length(peak_train)-artifact(k)<psthendsample-1)     % check the last artifact
            psthendsample= length(peak_train)-artifact(k)+1;
        end
        StimWin= peak_train (artifact(k):artifact(k)+psthendsample-1); % post-stimulus window
        StimWin(1:cancsample)= zeros(cancsample,1);                    % artifact blanking
        peak_index= find(StimWin);                                     % index of spikes within stim_win
        bin_num=(ceil(peak_index/binsample));                          % bin with spikes        
        for i=1:length(bin_num)
            psth_count (bin_num(i))= 1 + psth_count (bin_num(i));      % fill in the bins in the histogram
        end
        
        % Latency
        if isempty(peak_index)
            latency_el(k,1)= 0;
        else
            latency_el(k,1)= peak_index(1)*1000/fs;                    % latency measure in msec
        end

        % Array of stimuli
        FullStimWin(k, 1:length(StimWin))= StimWin';                    % save StimWin
        clear StimWin
    end    
    psth_count_non_norm = psth_count;
    psth_count = (psth_count/n); % Normalization - Maximum is '1' only if the PSTHbin==PDbin
else                                                                   % if there are no artifact
    psth_count = 0;                                                    % the histogram is empty
end
clear artifact peak_train fs bin StimWin peak_index bin_num k n i 

FullStimWin= sparse (FullStimWin);
if (sum(nonzeros(latency_el))>0)
    latency= [mean(nonzeros(latency_el)), std(nonzeros(latency_el)), ...
              stderror(mean(nonzeros(latency_el)), nonzeros(latency_el))]; % latency statistics
end
