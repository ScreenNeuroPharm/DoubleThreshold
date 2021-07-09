function [spkTs,spkLabel,nSamples,numElec,meanSpkRt] = Sparse2Pooled(trialFolder,minSpkRt,sf)
spkTs = [];
spkLabel = [];
% %%%
nSamples = getSamplesNumber(trialFolder);
numElec = getElectrodesNumber(trialFolder);
recDur_s = nSamples/sf;
%
files = dirr(trialFolder);
%
nElec = 0;
meanSpkRt = 0;
%

for ii = 1:numElec
    filename = fullfile(trialFolder,files(ii).name);
    load(filename);
    if sum(peak_train) > 0        % if there is at least one spike
        spkTsCurElec = find(peak_train);
        nspkTsCurElec = length(spkTsCurElec);
        spkRt = nspkTsCurElec/recDur_s;
        if spkRt >= minSpkRt
            nElec = nElec + 1;
            spkTs = [spkTs; spkTsCurElec(:)];
            spkLabel = [spkLabel; ii.*ones(nspkTsCurElec,1)];
            meanSpkRt = meanSpkRt+spkRt;
        end
    end
end
meanSpkRt = meanSpkRt/nElec;
numElec = nElec;