function [exp_num] = BurstDetection (peak_folder, nspikes, ISImax, min_mbr, fs, NumNeur, IBIwin, IBIbin)
% Function for producing the Burst Detection files
%
% by Michela Chiappalone (17 Marzo 2006, 12 Gennaio 2007)
% Modified by Paolo Massobrio (1st February 2016) in order to handle up
% 9999 simulated neurons
%
% --------------- Input & output folder management ------------------------
[exp_num]=find_expnum(peak_folder, '_PeakDetection'); % Experiment number
cd ..
burstfoldername = strcat (exp_num,'_BurstDetectionMAT_', num2str(nspikes), '-', num2str(ISImax), 'msec'); % Burst files here
mkdir (burstfoldername);
cd(burstfoldername);
[burst_folder]=pwd; % Save path
cd ..
[end_folder1]=createresultfolder(burst_folder, exp_num, 'BurstDetectionFiles');
[end_folder2]=createresultfolder(burst_folder, exp_num, 'BurstEventFiles');
[end_folder3]=createresultfolder(burst_folder, exp_num, 'OutBSpikesFiles');
clear burstfoldername expfolder

% DEFINE LOCAL VARIABLES
first = 3;
ISImaxsample = ISImax/1000*fs; % ISImax [sample]
cwin = 1;
cancwinsample = cwin/1000*fs; % cwin [sample]

% START PROCESSING
cd(peak_folder)
cd('ptrain_All1_1')                      % start_folder in the MAIN program
    phasedir= pwd;
    phasefiles= dir;
    NumPhaseFiles= length(phasefiles);
    burst_detection_cell = cell(NumPhaseFiles-2,1);  % cell array containing the burst features for each channel
    burst_event_cell     = cell(NumPhaseFiles-2,1); %  cell array containing the burst_event train for each channel
    outburst_spikes_cell = cell(NumPhaseFiles-2,1);  % cell array containing the random spikes features for each channel
    
    for i = first : NumPhaseFiles  % FOR cycle on the single directory files
        filename = phasefiles(i).name;    % current PKD file
        electrode= filename(end-7:end-4); % current electrode [char]     AVALANCHE SIMULATIONS
        el= str2num(electrode);           % current electrode [num]
        load (filename);                  % 'peak_train' and 'artifact' are loaded
        if exist('artifact')
            if (sum(artifact)>0) % if artifact exists
                [new_train]= delartcontr (new_train, artifact, cancwinsample); % Delete the artifact contribution
            end
        end
        if sum(new_train)>0
            timestamp=find(new_train); % Vector with dimension [nx1]
            allisi  =[-sign(diff(timestamp)-ISImaxsample)];
            allisi(find(allisi==0))=1;  % If the difference is exactly ISImax, I have to accept the two spikes as part of the burst
            edgeup  =find(diff(allisi)>1)+1;  % Beginning of burst
            edgedown=find(diff(allisi)<-1)+1; % End of burst
            
            if ((length(edgedown)>=2) & (length(edgeup)>=2))
                barray_init=[];
                barray_end=[];
                
                if (edgedown(1)<edgeup(1))
                    barray_init=[timestamp(1), timestamp(edgedown(1)), edgedown(1), ...
                        (timestamp(edgedown(1))-timestamp(1))/fs];
                    edgedown=edgedown(2:end);
                end
                
                if(edgeup(end)>edgedown(end))
                    barray_end= [timestamp(edgeup(end)), timestamp(end), length(timestamp)-edgeup(end)+1, ...
                        (timestamp(end)-timestamp(edgeup(end)))/fs];
                    edgeup=edgeup(1:end-1);
                end
                
                barray= [timestamp(edgeup), timestamp(edgedown), (edgedown-edgeup+1), ...
                    (timestamp(edgedown)-timestamp(edgeup))/fs];      % [init end nspikes duration-sec]
                barray= [barray_init;barray;barray_end];
                burst_detection=barray(find(barray(:,3)>=nspikes),:); % Real burst statistics
                
                [r,c]=size(burst_detection);
                acq_time=fix(length(new_train)/fs); % Acquisition time  [sec]
                mbr=r/(acq_time/60);                 % Mean Bursting Rate [bpm]
                clear  edgeup edgedown
                
                % THRESHOLD EVALUATION
                if (mbr>=min_mbr) % Save only if the criterion is met
                    
                    % OUTSIDE BURST Parameters
                    %%%%%%%%%%%%%%%%%%%%%% !!!!!WARNING!!!!! %%%%%%%%%%%%%%%%%%%%%%
                    tempburst= [(burst_detection(:,1)-1), (burst_detection(:,2)+1)];
                    % There is no check here: the +1 and -1 could be
                    % dangerous when indexing the peak_train vector
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    out_burst=reshape(tempburst',[],1);
                    out_burst=[1;out_burst; length(new_train)];
                    out_burst= reshape(out_burst, 2, [])';
                    [rlines, clines]=size(out_burst);
                    outburst_cell= cell(rlines,7);
                    
                    for k=1:rlines
                        outb_period=(out_burst(k,2)-out_burst(k,1))/fs; % duration [sec] of the non-burst period
                        outbspikes= find(new_train(out_burst(k,1):out_burst(k,2)));
                        
                        n_outbspikes=length(outbspikes);
                        mfob=n_outbspikes/outb_period;       % Mean frequency in the non-burst period
                        isi_outbspikes= diff(outbspikes)/fs; % ISI [sec] - for the spikes outside the bursts
                        f_outbspikes =1./isi_outbspikes;     % frequency between two consecutive spikes outside the bursts
                        
                        outburst_cell{k,1}= out_burst(k,1);  % Init of the non-burst period
                        outburst_cell{k,2}= out_burst(k,2);  % End of the non-burst period
                        outburst_cell{k,3}= n_outbspikes;    % Number of spikes in the non-burst period
                        outburst_cell{k,4}= mfob;            % Mean Frequency in the non-burst period
                        outburst_cell{k,5}= outbspikes;      % Position of the spikes in the non-burst period
                        outburst_cell{k,6}= isi_outbspikes;  % ISI of spikes in the non-burst period
                        outburst_cell{k,7}= f_outbspikes;    % Frequency of the spikes in the non-burst period
                    end
                    ave_mfob= mean(cell2mat(outburst_cell(:,4))); % Avearge frequency outside the burst - v1: all elements
                   
                    % INSIDE BURST Parameters
                    binit= burst_detection(:,1);             % Burst init [samples]
                    burst_event =sparse(binit, ones(length(binit),1), new_train(binit)); % Burst event
                    bp= [diff(binit)/fs; 0];                 % Burst Period [sec] - start-to-start
                    ibi= [((burst_detection(2:end,1)- burst_detection(1:end-1,2))/fs); 0]; % Inter Burst Interval, IBI [sec] - end-to-start
                    lastrow=[acq_time, length(find(new_train)), r, sum(burst_detection(:,3)), mbr, ave_mfob];
                    
                    burst_detection=[burst_detection, ibi, bp; lastrow];
                    
                    burst_detection_cell{el,1}= burst_detection; % Update the cell array
                    burst_event_cell{el,1}= burst_event;         % Update the cell array
                    outburst_spikes_cell{el,1}= outburst_cell;   % Update the cell array
                    
                    clear rlines clines out_burst tempburst
                end
            end
            clear peak_train artifact allisi acq_time mbr barray timestamp
            clear r c ibi binit burst_detection burst_event edgedown edgeup lastrow
        end
        cd (phasedir);
    end
    % SAVE ALL FILES
    cd(end_folder1) % Burst array
    nome=strcat('burst_detection_', exp_num);
    save(nome, 'burst_detection_cell');
    
    cd(end_folder2) % Burst event
    nome=strcat('burst_event_', exp_num);
    save(nome, 'burst_event_cell');
    
    cd(end_folder3) % Outside Burst Spikes
    nome=strcat('outburst_spikes', exp_num);
    save(nome, 'outburst_spikes_cell');
    cd ..\..
    % ------------- Net IBI computation, plotting and  saving -------------     
    f = strfind(phasedir,'All');
    if isempty(f)
        f = strfind(phasedir,'exc');
        if isempty(f)
            f = strfind(phasedir,'inh');
        end
    end
    NetIBIfilename = [exp_num,'_MeanIBI_',phasedir(f:f+2),'_neurons'];      
    [end_folder] = NetworkIBI(exp_num, NumNeur, burst_detection_cell, fs, IBIwin, IBIbin, NetIBIfilename);
    [BurstStatistics, SpikeStatistics] = BurstingSpikingStatistics (burst_detection_cell, exp_num, end_folder, phasedir);
%     ---------------------------------------------------------------------
    cd(peak_folder);

 cd ..
display ('Burst detection and analysis performed correctly!');