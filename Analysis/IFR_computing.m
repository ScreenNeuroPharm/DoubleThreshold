function [IFRTrace, binWidth] = IFR_computing(peakTrain,fs,kernelWidth,undersamplingFactor)

numSamples = length(peakTrain);
acqTime = numSamples/fs;
nspikes = sum(peakTrain > 0);
mfr = nspikes/acqTime;
% all the channels whose mfr < 0.1 spikes/s are considered not active
th = 0.1;
mfr(mfr < th) = 0;

if mfr~=0
    kernelWidth_samples = kernelWidth * 1e-3 * fs;   % [sample]
    % kernelWidth must be odd
    if ~rem(kernelWidth_samples,2)
        kernelWidth_samples = kernelWidth_samples+1;
    end
    kernel = gausswin(kernelWidth_samples);
    % normalize kernel
    kernel = kernel./sum(kernel);
    % only 0s and 1s
    peakTrain = spones(peakTrain);
    IFRTrace = sparseconv(peakTrain,kernel);
    semiWindow = (kernelWidth_samples-1)/2;
    IFRTrace = IFRTrace(semiWindow+1:end-(semiWindow));
    % now IFR is in spikes/sample --> I have to multiply it by commonParam.sf
    IFRTrace = IFRTrace * fs;
    if undersamplingFactor == 1
        IFRTrace = sparse(IFRTrace);
    else
        IFRTrace = sparse(IFRTrace(undersamplingFactor:undersamplingFactor:end));
    end
    binWidth = kernelWidth_samples/fs*1e+3;
else
    IFRTrace = zeros(floor(numSamples/undersamplingFactor),1);
    binWidth = 0;
    return
end