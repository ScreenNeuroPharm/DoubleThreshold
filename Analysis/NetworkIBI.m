function [end_folder] = NetworkIBI(exp_num, NumNeur, burst_detection_cell, fs, IBIwin, IBIbin, NetIBIfilename)
% This script plots the avearge IBI distribution evaluated over 1024
% neurons.
%
%      Paolo Massobrio   -    last update 2ndt February 2016
%
out_dir = pwd;
end_folder = [exp_num, '_BurstAnalysis'];
mkdir(end_folder);
cd(end_folder);
end_folder = pwd;
cd ..
neurons = [1:NumNeur]; % electrode names
% --------------- PLOT phase
IBIarray = [];
for i=1:NumNeur
    el = neurons(i);
    if ((el<=length(burst_detection_cell) && ~isempty( burst_detection_cell{el,1})))
        
        temp=burst_detection_cell{el,1};
        
        [r,c]=size(temp);
        if r>=3
            IBIarray = [IBIarray; burst_detection_cell{el,1}(1:end-2,5)];
        end
    end
end
figure()
[bins, n_norm, max_y] = f_single_IBIh_Model(IBIarray, fs, IBIwin, IBIbin);
% y = area(bins, n_norm);
y = bar(bins, n_norm);
hold on
if sum(n_norm ~=0)
    bins_spline = [bins(1):(bins(2)-bins(1))/10:bins(end)];
    n_norm_spline = spline(bins,n_norm,bins_spline);
    plot (bins_spline,n_norm_spline,'LineStyle', '-', 'col', 'r', 'LineWidth', 4);
end

set(y,'FaceColor',[0 1 1]);
set(y,'LineStyle','-','LineWidth',1.0);
axis ([0 IBIwin 0 1])
axis square
title ('Mean IBI Histogram','FontSize',12,'FontName','arial');
xlabel('Inter Burst Interval (s)','FontSize',12,'FontName','arial');
ylabel('Probability per bin','FontSize',12,'FontName','arial');
box off
% Saving phase
filename2 = [NetIBIfilename,'.mat'];
folder_name = strcat(exp_num,'BurstAnalysis');
SavingAnalysis(end_folder, NetIBIfilename, y);
cd(end_folder);
if sum(n_norm ~=0)
    Net_IBI = [bins_spline', n_norm_spline'];
    save(filename2,'Net_IBI','-mat');
end

