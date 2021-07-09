function[] =  aVa_evaluation(spkTs,spkLabel,nSamples,numElec, IEI_avg,fs)

binWidths = [];
numTrials = 1; %----------AAAAAAAAAAAAA
IEI = mean(IEI_avg);
allBinWidths = [binWidths IEI];
allBinWidths_samples = zeros(numel(allBinWidths),1);
numBins = length(allBinWidths);
% %%
aVaSize1 = cell(numTrials,numBins);
aVaSize2 = cell(numTrials,numBins);
aVaLifetime = cell(numTrials,numBins);
aVaStart = cell(numTrials,numBins);
aVaEnd = cell(numTrials,numBins);
nAva = zeros(numTrials,numBins);
% %%
aVaSize1Tot = cell(numTrials,numBins);
aVaSize2Tot = cell(numTrials,numBins);
aVaLifetimeTot = cell(numTrials,numBins);
aVaStartTot = cell(numTrials,numBins);
aVaEndTot = cell(numTrials,numBins);
%     nAvaTot = zeros(1,numBins);
alphaSize1 = zeros(numTrials,numBins);
xminSize1 = zeros(numTrials,numBins);
Lsize1 = zeros(numTrials,numBins);
%
alphaSize2 = zeros(numTrials,numBins);
xminSize2 = zeros(numTrials,numBins);
Lsize2 = zeros(numTrials,numBins);
%
alphaLifetime = zeros(numTrials,numBins);
xminLifetime = zeros(numTrials,numBins);
Llifetime = zeros(numTrials,numBins);
%
for ii = 1:numTrials
    %          curFullFilename = trialsFullfileNames{ii};
    %          load(curFullFilename)
    %   [spkTs,spkLabel,nSamples,numElec] = aVa4IDEA_loadData(curFullFilename,minSpkRt,sf,duration);
    %   nSamples = length(spkTs);
    %   [IEI_avg(ii),IEI_std(ii),IEI_ste(ii),maxIEIth_actual] = aVa4IDEA_IEIcomput(spkTs,sf,maxIEIth);
    for bb = 1:numBins
        allBinWidths_samples(bb) = ceil(allBinWidths(bb)/1000*fs);
        [aVaSize1{ii,bb},aVaSize2{ii,bb},aVaLifetime{ii,bb},aVaStart{ii,bb},aVaEnd{ii,bb},nAva(ii,bb), aVaShape1, aVaShape2] = aVa_comput(spkTs,spkLabel,nSamples,numElec,allBinWidths_samples(bb));
    end
end
newBinWidths_ms = allBinWidths_samples./fs.*1000;
nAvaTot = sum(nAva,1);
%     saveFilename = fullfile(aVaResFolder,[string,'_IEIresults.mat']);
%     save(saveFilename,'IEI_avg','IEI_std','IEI_ste', 'maxIEIth_actual')
%     clear saveFilename
%     clear ii bb
%     allBinWidths = [binWidths mean(IEI_avg)];

% --- definition of arrays containing the GoF for all the used bins ---
gofSize1 = zeros(ii,numBins);
gofSize2 = zeros(ii,numBins);
gofLifetime = zeros(ii,numBins);
%
for ii = 1:numTrials
    for bb = 1:numBins
        binWidth_ms = newBinWidths_ms(bb);
        [aVaSize1Tot{ii,bb},aVaSize2Tot{ii,bb},aVaLifetimeTot{ii,bb},aVaStartTot{ii,bb},aVaEndTot{ii,bb}] = aVa_catData(aVaSize1(ii,bb),aVaSize2(ii,bb),aVaLifetime(ii,bb),aVaStart(ii,bb),aVaEnd(ii,bb));
        % %% FITTING %%
        % 1. MLE estimation
        [alphaSize1(ii,bb), xminSize1(ii,bb), Lsize1(ii,bb)] = plfit(aVaSize1Tot{ii,bb},'range',[1.001:0.001:3.501],'xmin',2);
        [alphaSize2(ii,bb), xminSize2(ii,bb), Lsize2(ii,bb)] = plfit(aVaSize2Tot{ii,bb},'range',[1.001:0.001:3.501],'xmin',2);
        [alphaLifetime(ii,bb), xminLifetime(ii,bb), Llifetime(ii,bb)] = plfit(aVaLifetimeTot{ii,bb},'range',[1.001:0.001:3.501],'xmin',2);
        % 2. Plot (CDF + MLE fit)
        h1 = plplot(aVaSize1Tot{ii,bb}, xminSize1(ii,bb), alphaSize1(ii,bb), 'size1');
        h2 = plplot(aVaSize2Tot{ii,bb}, xminSize2(ii,bb), alphaSize2(ii,bb), 'size2');
        h3 = plplot(aVaLifetimeTot{ii,bb}, xminLifetime(ii,bb), alphaLifetime(ii,bb), 'lifetime');
        % 3. Plot (PDF + linear regression)
        [h8, h9, h10] = aVa_plotFig_separate(aVaSize1Tot{ii,bb},aVaSize2Tot{ii,bb},aVaLifetimeTot{ii,bb});
        set(h8,'PaperPositionMode','auto')
        set(h9,'PaperPositionMode','auto')
        set(h10,'PaperPositionMode','auto')
        % --- Goodness-of-fit evaluations (Kolmogorov-Smirnov distance) ---
        [gofSize1(ii,bb)] = computeGof_KS(aVaSize1Tot{ii,bb}, xminSize1(ii,bb),alphaSize1(ii,bb));
        [gofSize2(ii,bb)] = computeGof_KS(aVaSize2Tot{ii,bb}, xminSize2(ii,bb),alphaSize2(ii,bb));
        [gofLifetime(ii,bb)] = computeGof_KS(aVaLifetimeTot{ii,bb}, xminLifetime(ii,bb),alphaLifetime(ii,bb));
        
        stringFig1 = 'CDF_aVa';
        stringFig2 = 'PDF_aVa';
    end
    aVaResFolder = 'aVa_results';
    mkdir(aVaResFolder);
    aVaFigSaving(aVaResFolder, stringFig1, binWidth_ms, stringFig2, h1, h2, h3, h8, h9, h10);
    close all
    %
    cd(aVaResFolder);
    saveFilename = 'allPhases_BinSizes_results.mat';
    save(saveFilename,'aVaSize1Tot','aVaSize2Tot','aVaLifetimeTot','aVaStartTot','aVaEndTot','nAvaTot','newBinWidths_ms','aVaShape1','aVaShape2')
    %
    saveFilename = 'allPhases_MLEfitting_results.mat';
    save(saveFilename, 'alphaSize1', 'xminSize1', 'Lsize1', 'alphaSize2', 'xminSize2', 'Lsize2', 'alphaLifetime', 'xminLifetime', 'Llifetime')
    %
    saveFilename = 'allPhases_Gof_KS_results.mat';
    save(saveFilename,'gofSize1','gofSize2','gofLifetime')
    %
    close all
end
cd ..



