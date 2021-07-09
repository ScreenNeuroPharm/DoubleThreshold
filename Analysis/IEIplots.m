function [] = IEIplots(allIEI_ms)
% This function plots and save the IEI distribution
% 
%       Paolo Massobrio - last update 18th May 2016

edges = unique(allIEI_ms);
IEIhist = hist(allIEI_ms,edges)' ./ length(allIEI_ms);
h1 = figure();
plot(edges,IEIhist,'bo','MarkerSize',8,'MarkerFaceColor',[1 1 1]); 
hold on;
ylabel('P(IEI)','FontSize',16);
xlabel('IEI (ms)','FontSize',16);
h2 = figure();
loglog(edges,IEIhist,'bo','MarkerSize',8,'MarkerFaceColor',[1 1 1]);
hold on;
ylabel('P(IEI)','FontSize',16);
xlabel('IEI (ms)','FontSize',16);
% saving
saveFig1Filename = 'IEIhist_lin.fig';
saveTif1Filename = 'IEIhist_lin.tif';
saveFig2Filename = 'IEIhist_log.fig';
saveTif2Filename = 'IEIhist_log.tif';
%
saveas(h1,saveFig1Filename,'fig');
saveas(h1,saveTif1Filename,'tif');
saveas(h2,saveFig2Filename,'fig');
saveas(h2,saveTif2Filename,'tif');
cd ..

