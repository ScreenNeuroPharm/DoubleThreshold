% aVa4IDEA_IEIcomput.m
function [IEI_avg,IEI_std,IEI_ste,allIEITh_ms,th] = IEI_aVa_comput(spkTs,sf,th)
if nargin < 3
    th = 100;
end
spkTsSorted = sort(spkTs);
allIEI_samples = diff(spkTsSorted);
allIEI_ms = allIEI_samples./sf.*1e+3;
% prcTh = prctile(allIEI_ms,99);
% if prcTh < th
%     th = prcTh;
% end
allIEITh_ms = allIEI_ms(allIEI_ms <= th);
IEI_avg = mean(allIEITh_ms);
IEI_std = std(allIEITh_ms);
IEI_ste = stderror(IEI_avg,allIEITh_ms);