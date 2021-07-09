function [dir_name1] = SpikeDetectionModel(Firings, artifact, NumNeur,fs,NumHours,Stimulation, NeuronId2Stimulate)
% This scripts performs the spike detection of the simulations. Output
% files are arranged following the typical nomenclature and structure used
% for the experimental data.
%
%                  last update 4th October 2016 Paolo Massobrio
%

tstop_sec = (NumHours*60*60);     % sec
if Stimulation == 0
    prefix = 'ptrain_nbasal1';
else
    prefix = 'ptrain_stim1';
end
dir_name1 = strcat('01_PeakDetectionMAT_files_',num2str(NumNeur),'neurons');
mkdir (dir_name1);
if Stimulation == 0
    dir_name2 = ('ptrain_All1_1');
else
    dir_name2 = strcat('ptrain_stim1_', num2str(NeuronId2Stimulate));
end
cd(dir_name1);
dir_name1 = pwd;
mkdir (dir_name2);
cd(dir_name2);

pt_size = tstop_sec * fs;           % Peak Train size [samples];
if (pt_size - ceil(pt_size)) ~= 0   % if the recording is not int
    pt_size = ceil(pt_size);
end

ms2sec = 1e-3;                      % Conversion factor: ms --> s
% Data extraction from the model
for i = 1:NumNeur
    index = find (Firings(:,2) == i);   % Neuron Number
    t = [Firings(index,1)] * ms2sec;    % Time stamp of the neuron i [s]
    sample_spk = single(t * fs);        % Spike occurance [samples]
    
    if i <= 9
        channel = strcat('000',num2str (i));            % Channel number
    elseif i >= 10 & i <= 99
        channel = strcat('00',num2str (i));             % Channel number
    elseif i >= 100 & i <=999
        channel = strcat('0',num2str (i));              % Channel number
    else i >= 1000 & i <=9999
        channel = num2str (i);                          % Channel number
    end
    % Sparse Matrix conversion
    z = zeros(pt_size,1);
    for j = 1:size(sample_spk,1);
        if sample_spk(j,1)~=0
            z(sample_spk(j,1)) = 1;
        end
    end
    peak_train = sparse(z);
%     artifact = []; % For taking into account artifact and allowing analysis
    % Saving Peak Train
    filename = strcat (prefix,'_',channel,'.mat');
    save (filename,'peak_train','artifact','-MAT');
end
cd ..\..