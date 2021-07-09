function[] = MFR(start_folder, NumNeur, fs, mfr_thresh)
% MFR.m script evaluates the MFR of an arbitrary neuronal networks made up
% of N neurons. The provided output furnishes the mfr_table variable
% containig the MFR of each neuron, MFR_global containig the avereged
% values and a histogram of the occurences of the MFR.
%
%               Paolo Massobrio - last up-date 30 September 2009
%

% --------------- VARIABLES
cancwin = 1;        % 1 ms
cancwinsample = cancwin/1000*fs;
first = 3;       firingch = [];
artifact = [];   totaltime = [];
new_train = []; neurons = (1:NumNeur)';

[exp_num]=find_expnum(start_folder, '_PeakDetection');
[SpikeAnalysis]=createSpikeAnalysisfolder(start_folder, exp_num);
final_string = strcat('MeanFiringRate - thresh_', num2str(mfr_thresh));
[end_folder]=createresultfolder(SpikeAnalysis, exp_num, final_string);

% --------------------- START PROCESSING ----------------------------
cd (start_folder)         % Go to the PeakDetectionMAT folder
name_dir = dir;               % Present directories - name_dir is a struct
num_dir = length (name_dir);  % Number of present directories (also "." and "..")
nphases = num_dir-first+1;
allmfr_mean = zeros(nphases,1);
allmfr_std = zeros(nphases,1);

for i = first:num_dir     % FOR cycle over all the directories
    current_dir = name_dir(i).name;   % i-th directory - i-th experimental phase
    phasename=current_dir;
    cd (current_dir);                 % enter the i-th directory
    current_dir=pwd;
    content=dir;                      % current PeakDetectionMAT files folder
    num_files= length(content);       % number of present PeakDetection files
    mfr_table= zeros (NumNeur,2);     % vector for MFR allocated (NumNeur x 2)
    mfr_table(:,1)= neurons;          % First column = electrode names
    
    for k = first:num_files  % FOR cycle over all the PeakDetection files
        filename = content(k).name;
        load (filename);                      % peak_train and artifact are loaded
        electrode = filename(end-6:end-4);     % current electrode [char]  7
        el = str2num(electrode);               % current electrode [double]
        ch_index = find(neurons == el);
        
        if (sum(artifact)>0) % if artifact exists
            [new_train]= delartcontr (new_train, artifact, cancwinsample);
        end
        numpeaks=length(find(new_train));
        acq_time=length(new_train)/fs;            % duration of acquisition [sec]
        mfr_table(ch_index, 2)= numpeaks/acq_time; % Mean Firing Rate [spikes/sec]
    end
    
    mfr_table= mfr_table(find(mfr_table(:,2)>=mfr_thresh), :); % MFR threshold
    
    % Evaluation of the mean and std of the MFR over all the neurons
    [r,c] = size(mfr_table);
    if r ~= 0           % at least one neuron is active
        allmfr_mean(i-first+1,1) = mean(mfr_table(:,2));
        allmfr_std(i-first+1,1) = std(mfr_table(:,2));
        totaltime = [totaltime; acq_time]; % Total duration of the experiment [s]
        firingch = [firingch; r];
        MFR_global = struct('MFR_mean',allmfr_mean,'MFR_sd',allmfr_std,'Duration',totaltime,'Firing_channels',firingch);
      if length(mfr_table)==500  
        % Plotting the MFR histo of occurences
        [y_exc,x_exc] = histcounts(mfr_table(1:400,2));
        [y_inh,x_inh] = histcounts(mfr_table(401:end,2));
        h = figure;
        %axis square
        %axis([0 x_max 0 ceil(max(y))]);
        ex=plot(x_exc(2:end)-0.1,(y_exc),'r','LineWidth',2);
        hold on 
        in=plot(x_inh(2:end)-0.1,(y_inh),'b','LineWidth',2);
        xlabel('MFR (sp/s)','FontSize',14,'FontName','arial');
        ylabel('# occurences','FontSize',14,'FontName','arial');
        legend([ex in],{'Excitatory','Inhibitory'})
        title('MFR distribution')
        % Saving numeric and graphical results
        cd(end_folder);
        name = strcat('MFR', phasename(7:end));         % MAT file name
        save (name, 'mfr_table','MFR_global');          % variables storing
        %     save (strcat(name,'.txt'), 'mfr_table', '-ASCII');
        saveas(h,strcat(name,'.jpg'));
        close(h);
      end
        cd (start_folder);
    end
cd (start_folder);
end
cd(end_folder);
if exist('MFR_global')
    save ('MFR_global','MFR_global'); % variables storing
end
cd (start_folder);
cd ..
clear;
display('MFR analysis ended!');
