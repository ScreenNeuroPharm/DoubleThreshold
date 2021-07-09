function [BurstStatistics, SpikeStatistics] = BurstingSpikingStatistics (burst_detection_cell, exp_num, end_folder, phasedir)

% MAIN_StatisticsReportMean.m
% by Michela Chiappalone (12 Aprile 2006)
% Probably it needs to be updated on the basis of the other scripts on
% burst detection, already changed
% modified by Luca Leonardo Bologna
%   - in order to handle the 64 channels of MED64 Panasonic System

[end_folder1]=createresultfolder(end_folder, exp_num, 'MeanStatReportBURST');
[end_folder2]=createresultfolder(end_folder, exp_num, 'MeanStatReportSPIKEinBURST');
% 
% --------------> COMPUTATION PHASE: Create Statistics Report
    SRMburst=[];
    SRMspike=[];

    for k=1:length(burst_detection_cell)
        burst_detection=burst_detection_cell{k,1};

        if ~isempty(burst_detection_cell{k,1})
            acq_time=burst_detection(end,1); % Acquisition time [sec]

            % Burst Features
            totalbursts= burst_detection(end,3);            % total # of bursts
            spikesxburst=  burst_detection(1:end-1,3);      % # of spikes in burst
            burstduration= burst_detection(1:end-1,4)*1000; % Burst Duration[msec]
            ibi= burst_detection(1:end-2,5);                % IBI start-to-start [sec]
            mbr= burst_detection(end,5);                    % mbr [#bursts/min]

            % Spike Features
            totalspikes= burst_detection(end,2);                                    % total # of spikes
            mfr= totalspikes/acq_time;                                              % mfr [#spikes/sec]
            totalburstspikes= burst_detection(end,4);                               % total # of intra-burst spikes
            percrandomspikes= ((totalspikes-totalburstspikes)/totalspikes)*100;     % Percentage of random spikes
            mfb=(spikesxburst./burstduration)*1000;                                 % mfb = mean freq intraburst [#spikes/sec]
            pfb= max(mfb);                                                          % peak frequency intra burst

            % Fill in the StatReportMean arrays
            lastrow= [k, acq_time, mbr, totalbursts, ...
                mean(spikesxburst), stderror(mean(spikesxburst), spikesxburst),...
                mean(burstduration), stderror(mean(burstduration), burstduration),...
                mean(ibi), stderror(mean(ibi), ibi)];
            SRMburst=[SRMburst; lastrow];
            clear lastrow

            lastrow=  [k, acq_time, totalspikes, totalburstspikes, percrandomspikes, ...
                pfb, mean(mfb), stderror(mean(mfb), mfb)];
            SRMspike= [SRMspike; lastrow];
            clear lastrow
        end
    end
    
    BurstStatistics = mat2dataset(SRMburst);
    BurstStatistics.Properties.VarNames = {'neuron_id','acq_time_s','MBR_bursts_min','NumBursts',...
                            'NumSpikes_in_burst','std1','BurstDur_ms','std2','IBI_s','std3'};
    
    SpikeStatistics = mat2dataset(SRMspike);
    SpikeStatistics.Properties.VarNames = {'neuron_id','acq_time_s','NumSpikes','NumSpikesIntraBurst',...
                            'PercRndSpikes','PeakFreqIntraBurst','MFB_sp_s','std'};
                    
    % Mean Stat Report MAT - Burst
    cd (end_folder1)
    sep = max(strfind(phasedir,'\'));
    nome=strcat('BurstStat_', phasedir(sep+1:end));
    save(nome, 'BurstStatistics')
    clear nome

    % Mean Stat Report MAT - Spikes
    cd (end_folder2)
    nome=strcat('SpikeStat_', phasedir(sep+1:end));
    save(nome, 'SpikeStatistics')
    clear nome
    cd ..\..
