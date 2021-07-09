function [] = IFRtracePlot(CUM_IFR, fs, undersamplingFactor,IFR_folder, NumNeur, Firings, NumHours)
% This function plots the IFR averaged over the entire neuronal
% populations. Such a trace can be estimated using two binwidths.
% In addition raster plot and IFR are plotted together.
% 
%            Paolo Massobrio - last update 31st May 2016

tstop = (length(CUM_IFR{1,1})/fs) * undersamplingFactor;
t = [0:undersamplingFactor/fs:tstop];
col = ['k','r'];
thick = [0.5,2];
h1 = figure();
hold on;
for i = 1:size(CUM_IFR,1)
    plot(t(1:end-1),CUM_IFR{i,1},'LineWidth',thick(i),'Color',col(i));
end
xlabel('Time (s)','FontSize',14,'FontName','arial');
ylabel('IFR (sp/s)','FontSize',14,'FontName','arial');
axis([0 (NumHours * 60 * 60) 0 ceil(max(CUM_IFR{1,1}))+1]);

cd(IFR_folder);
saveas(h1,'IFRtrace.fig','fig');
saveas(h1,'IFRtrace.jpg','jpg');
% -------------- Raster + IFR ---------
h2 = figure();
ms2sec = 1e-3;
if ~isempty(Firings)
    plot(Firings(2:end,1)*ms2sec,Firings(2:end,2),'.k','MarkerSize',4);
    ylabel('# Neuron','FontSize',14,'FontName','arial');
    axis([0 (NumHours * 60 * 60) 0 NumNeur]);
end
hold on
plot(t(1:end-1),CUM_IFR{2,1},'LineWidth',thick(2),'Color',col(2));

axis([0 (NumHours * 60 * 60) 0 ceil(max(CUM_IFR{1,1}))+1]);
xlabel('Time (s)','FontSize',14,'FontName','arial');
ylabel('IFR (sp/s)','FontSize',14,'FontName','arial');

cd(IFR_folder);
saveas(h2,'RasterPlot_IFRtrace.fig','fig');
saveas(h2,'RasterPlot_IFRtrace.jpg','jpg');

cd ..;
