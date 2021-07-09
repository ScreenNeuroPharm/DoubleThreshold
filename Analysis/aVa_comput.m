% aVa4IDEA_comput.m
function [aVaSize1,aVaSize2,aVaLifetime,aVaStart,aVaEnd,naVa, aVaShape1, aVaShape2] = aVa_comput(spkTs,spkLabel,nSamples,numElec,binSize_samples)
% spkTs = timestamps of all spikes
% spkLabel = labels (#elec) of corresponding spikes, referring to spkTs
% nSamples = number of samples
% rounded to the nearest integer
% binSize_samples = ceil(binSize/1000*sf);     % bin width [samples]
% edges of histogram
x = (0:binSize_samples:(binSize_samples*fix(nSamples./binSize_samples)))+1;
nBins = length(x);
[hSpks,binIdx] = histc(spkTs,x);
spkClass = [spkTs spkLabel binIdx];
clear spkTs spkLabel binIdx
tic
for ee = 1:numElec % FOR each electrode
    spkIdxCurElec = find(spkClass(:,2)==ee);
    if ~isempty(spkIdxCurElec)
        % %%% questa istruzione serve se ci sono elettrodi che si
        % %%% riattivano più volte nello stesso bin: binIdx (III colonna di spkClass) contiene
        % %%% per ogni spike l'indice del bin al quale appartiene;
        % %%% seleziono gli spikes di un elettrodo e mi chiedo se
        % %%% ci sono spike consecutivi con lo stesso binIdx
        % %%% (diff(binIdx)==0); se ci sono vengono eliminati
        discardSpkIdx = find(diff(spkClass(spkIdxCurElec,3))==0)+spkIdxCurElec(1);
        spkClass(discardSpkIdx,:) = [];
    end
end
hElecs = histc(spkClass(:,3),1:nBins);
%     hElecs = histc(spkClass(:,1),x);
% this is the same thing: hElecs = histc(spkClass(:,1),x);
emptyBinIdx = find(hElecs==0);
demptyBinIdx = diff(emptyBinIdx);
longInterv = find(demptyBinIdx>1);
aVaStart = emptyBinIdx(longInterv)+1;
aVaEnd = emptyBinIdx(longInterv+1)-1;
if emptyBinIdx(1)~=1
    aVaStart = [1;aVaStart];
    aVaEnd = [emptyBinIdx(1)-1;aVaEnd];
end
if emptyBinIdx(end)~=nBins
    aVaStart = [aVaStart;emptyBinIdx(end)+1];
    aVaEnd = [aVaEnd;nBins];
end
aVaLifetime = (aVaEnd-aVaStart)+1;
naVa = length(aVaStart);
aVaSize1 = zeros(naVa,1);
aVaSize2 = zeros(naVa,1);
aVaShape1 = cell(naVa,1);                                                  % PAOLO, for aVa shape! 24th April 2014
aVaShape2 = cell(naVa,1);                                                  % PAOLO, for aVa shape! 24th April 2014
for jj = 1:naVa
    aVaSize1(jj) = sum(hElecs(aVaStart(jj):aVaEnd(jj)));
    aVaShape1{jj} = hElecs(aVaStart(jj):aVaEnd(jj));                       % PAOLO, for aVa shape! 24th April 2014
    % select binIdx that belong to the interval
    % [aVaStart(jj),aVaEnd(jj)]
    spkIdxCurAva = spkClass(:,3)>=aVaStart(jj) & spkClass(:,3)<=aVaEnd(jj);
    % select corresponding electrodes numbers
    elecCurAva = spkClass(spkIdxCurAva,2);
    % sorts electrodes numbers, computes diff, finds 0s and adds 1 -->
    % indexes of electrodes reactivations
    elecCurAvaSort = sort(elecCurAva,1,'ascend');
    elecReact = find(diff(elecCurAvaSort)==0)+1;
    % deletes electrodes reactivations
    elecCurAvaSort(elecReact)=[];
    % calculates number of electrodes involved
    aVaSize2(jj) = length(elecCurAvaSort);
    aVaShape2{jj} = elecCurAvaSort;
end
toc