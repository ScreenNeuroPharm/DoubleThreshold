function [h] = Raster_Global(NumNeur, Firings,NumHours)
% This function draws a rasterplot starting from a n x 2 matrices
% which is the output of the model (i.e., Firings matrix)
% 
%           Paolo Massobrio - last update 16th September 2016

h = figure();
ms2sec = 1e-3;
if ~isempty(Firings)
    plot(Firings(2:end,1)*ms2sec,Firings(2:end,2),'.k','MarkerSize',4);
    xlabel('Time (s)','FontSize',12,'FontName','arial');
    ylabel('# Neuron','FontSize',12,'FontName','arial');
    axis([0 (NumHours * 60 * 60) 0 NumNeur]);
end
out_folder = 'RasterPlot';
mkdir(out_folder);
cd(out_folder);
saveas(h,'RasterPlot.fig','fig');
saveas(h,'RasterPlot.jpg','jpg');
cd ..;