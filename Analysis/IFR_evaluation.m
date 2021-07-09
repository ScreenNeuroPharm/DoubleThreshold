function [IFR_TABLE,CUM_IFR,IFR_folder] = IFR_evaluation(PDfolder,fs,KernelWidth,undersamplingFactor)

IFR_TABLE = cell(size(KernelWidth,2),1);
CUM_IFR = cell(size(KernelWidth,2),1);

for ww = 1:size(KernelWidth,2)
    cd(PDfolder);
    d = dir;
    for j = 3:length(d)
        foldername = d(j).name;
        if strfind(foldername, '_All');
            cd(foldername)
            dd = dir;
            for k = 3:length(dd)
                filename = dd(k).name;
                elecNumbers(k-2) = str2double(filename(end-7:end-4));
                load(filename);
                if sum(new_train) > 0        % if there is at least one spike
                    cancwin = 4; % [ms]
                    if exist('artifact','var') && ~isempty(artifact) && ~isscalar(artifact)
                        new_train = delartcontr(new_train, artifact, cancwin); % Delete the artifact contribution
                    end
                    %%%%%%%%%
                    %       peakTrain = peak_train(1:length(peak_train));
                    %                 Tdur = sim_dur;
                    %                 peakTrain = peak_train(1: Tdur * fs);                       % I do not know why, but sometimes are dfferent in length. Fix the length
                    %                 clear peak_train artifact
                    kernelWidth = KernelWidth(ww);
                    [IFRTable(:,k-2), binSizes(k-2)] = IFR_computing(new_train,fs,kernelWidth,undersamplingFactor);
                    clear new_train
                else
                    IFRTable(:,k-2) = zeros(floor(numberOfSamples/computParam.undersamplingFactor),1);
                    binSizes(k-2) = 0;
                end
            end
            cumIFR = sum(IFRTable,2);
            
            IFR_TABLE{ww,1} = IFRTable;
            CUM_IFR{ww,1} = cumIFR;
            cd ..\..
            clear IFRTable cumIFR
        end
    end
    
end

out_folder = 'IFR';
mkdir(out_folder);
cd(out_folder);
IFR_folder = pwd;
filename = 'IFRanalysis.mat';
save(filename, 'IFR_TABLE','CUM_IFR','KernelWidth','undersamplingFactor','-v7.3');
cd ..


