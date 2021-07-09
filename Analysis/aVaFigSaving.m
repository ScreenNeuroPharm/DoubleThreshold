function [] = aVaFigSaving(aVaResFolder, stringFig1, binWidth_ms, stringFig2, h1, h2, h3, h8, h9, h10)

saveFig1Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaSize1.fig']);
saveFig2Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaSize2.fig']);
saveFig3Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaLifetime.fig']);
saveTif1Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaSize1.tif']);
saveTif2Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaSize2.tif']);
saveTif3Filename = fullfile(aVaResFolder,[stringFig1,'_binSize_',num2str(binWidth_ms),'ms_aVaLifetime.tif']);
%
saveas(h1,saveFig1Filename,'fig')
saveas(h1,saveTif1Filename,'tif')
saveas(h2,saveFig2Filename,'fig')
saveas(h2,saveTif2Filename,'tiff')
saveas(h3,saveFig3Filename,'fig')
saveas(h3,saveTif3Filename,'tiff')
%
saveFig1FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaSize1.fig']);
saveFig2FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaSize2.fig']);
saveFig3FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaLifetime.fig']);
saveTif1FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaSize1.tif']);
saveTif2FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaSize2.tif']);
saveTif3FilenameCL = fullfile(aVaResFolder,[stringFig2,'_binSize_',num2str(binWidth_ms),'ms_aVaLifetime.tif']);
%
saveas(h8,saveFig1FilenameCL,'fig')
saveas(h8,saveTif1FilenameCL,'tif')
saveas(h9,saveFig2FilenameCL,'fig')
saveas(h9,saveTif2FilenameCL,'tif')
saveas(h10,saveFig3FilenameCL,'fig')
saveas(h10,saveTif3FilenameCL,'tif')



