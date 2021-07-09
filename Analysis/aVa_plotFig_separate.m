% aVa4IDEA_plotFig.m
function [h1, h2, h3] = aVa_plotFig_separate(aVaSize1,aVaSize2,aVaLifetime)
% scrsz = get(0,'ScreenSize');
% h = figure('Position',[0 scrsz(4)/4 scrsz(3) scrsz(4)/2]);
maxProb = 1e-2;
dtLog = 0.2;
numAva = length(aVaSize1);
th = maxProb*numAva;
if(~isempty(aVaSize1))
%     a1 = axes('OuterPosition',[0 0 1/3 1]);
    h1 = figure;
    % lin binning & fit
    maxaVaSize1 = round(max(aVaSize1)/10)*10;
    x1 = 1:1:maxaVaSize1;
    histAvaSize1 = histc(aVaSize1,x1);
%     histAvaSize1Norm = histAvaSize1;
%     histAvaSize1Norm = histAvaSize1/numAva;
    outliers1 = histAvaSize1<th;
    histAvaSize12Fit = log10(histAvaSize1(~outliers1));
    x12Fit = log10(x1(~outliers1));
    p1 = polyfit(x12Fit(:),histAvaSize12Fit(:),1);
    p1Eval = 10^p1(2).*(x1).^p1(1);
    %% -----------------  log binning    
%     maxaVaSize1Log = ceil(log10(maxaVaSize1));
%     x1Log = logspace(0, maxaVaSize1Log, maxaVaSize1Log/dtLog);
%     histAvaSize1Log = histc(aVaSize1,x1Log);
%     binSizes = [1 x1Log(2:end)-x1Log(1:end-1)]';

%     histAvaSize1LogNorm = (histAvaSize1Log(1:end-1)./binSizes)/numAva;
%     histAvaSize1LogNorm = (histAvaSize1Log./binSizes);
%     outliers1Log = histAvaSize1Log<th;
%     histAvaSize1LogFit = log10(histAvaSize1LogNorm(~outliers1Log));
%     x1LogFit = log10(x1Log(~outliers1Log));
%     p1Log = polyfit(x1LogFit(:),histAvaSize1LogFit(:),1);
%     p1LogEval = 10^p1Log(2).*(x1Log).^p1Log(1); 
%%
    pl1 = 1e+5.*(x1).^(-1.5);
    %
    loglog(x1,histAvaSize1,'k.-');
    hold all
%     loglog(x1Log,histAvaSize1LogNorm','r.-');
    loglog(x1(~outliers1),p1Eval(~outliers1),'r--','LineWidth',2)
%     loglog(x1Log(~outliers1Log),p1LogEval(~outliers1Log),'r--','LineWidth',2)
    loglog(x1(3:end-3),pl1(3:end-3),'k-.','LineWidth',2)
    
    title('Size1')
    xlabel('# units','FontSize',14,'FontName','arial')
%     ylabel('P(size)','FontSize',14,'FontName','arial')
    ylabel('Frequency','FontSize',14,'FontName','arial');
%     legend('lin bin','log bin',['slope: ',num2str(p1(1))],['slope: ',num2str(p1Log(1))],'slope: -1.5')
    legend('data',['slope: ',num2str(p1(1))],'ref slope: -1.5')

    axis square
end
if(~isempty(aVaSize2))
%%     a2 = axes('OuterPosition',[1/3 0 1/3 1]);
    h2 = figure;
    % lin binning
    maxaVaSize2 = round(max(aVaSize2)/10)*10;
    x2 = 1:1:maxaVaSize2;
    histAvaSize2 = histc(aVaSize2,x2);
%     histAvaSize2Norm = histAvaSize2;
%     histAvaSize2Norm = histAvaSize2/numAva;
    outliers2 = histAvaSize2<th;
    histAvaSize22Fit = log10(histAvaSize2(~outliers2));
    x22Fit = log10(x2(~outliers2));
    p2 = polyfit(x22Fit(:),histAvaSize22Fit(:),1);
    p2Eval = 10^p2(2).*(x1).^p2(1);
    %% log binning
%     maxaVaSize2Log = ceil(log10(maxaVaSize2));
%     x2Log = logspace(0, maxaVaSize2Log, maxaVaSize2Log/dtLog);
%     histAvaSize2Log = histc(aVaSize2,x2Log);
%     binSizes = [1 x2Log(2:end)-x2Log(1:end-1)]';
% %     histAvaSize2LogNorm = (histAvaSize2Log(1:end-1)./binSizes)/numAva;
%     histAvaSize2LogNorm = (histAvaSize2Log./binSizes);
%     outliers2Log = histAvaSize2Log<th;
%     histAvaSize2LogFit = log10(histAvaSize2LogNorm(~outliers2Log));
%     x2LogFit = log10(x2Log(~outliers2Log));
%     p2Log = polyfit(x2LogFit(:),histAvaSize2LogFit(:),1);
%     p2LogEval = 10^p2Log(2).*(x2Log).^p2Log(1); 
    %%
    pl2 = 1e+5.*(x2).^(-1.5);
    %
    loglog(x2,histAvaSize2,'k.-');
    hold all
%     loglog(x2Log,histAvaSize2LogNorm','r.-');
    loglog(x2(~outliers2),p2Eval(~outliers2),'r--','LineWidth',2)
%     loglog(x2Log(~outliers2Log),p2LogEval(~outliers2Log),'r--','LineWidth',2)
    loglog(x2(3:end-3),pl2(3:end-3),'k-.','LineWidth',2)
    %
    title('Size2')
    xlabel('size(# neurons)','FontSize',14,'FontName','arial')
%     ylabel('P(size)','FontSize',14,'FontName','arial')
    ylabel('Frequency','FontSize',14,'FontName','arial')
%     legend('lin bin','log bin',['slope: ',num2str(p2(1))],['slope: ',num2str(p2Log(1))],'slope: -1.5');
    legend('data',['slope: ',num2str(p2(1))],'ref slope: -1.5');
    axis square
end
%%
if(~isempty(aVaLifetime))
%     a3 = axes('OuterPosition',[2/3 0 1/3 1]);
    h3 = figure;
    % lin binning
    maxLifetime = round(max(aVaLifetime)/10)*10;
    x3 = 1:1:maxLifetime;
%     histAvaLifetimeNorm = histc(aVaLifetime,x3)/numAva;
    histAvaLifetime = histc(aVaLifetime,x3);
    outliers3 = histAvaLifetime<th;
    histAvaLifetime2Fit = log10(histAvaLifetime(~outliers3));
    x32Fit = log10(x3(~outliers3));
    p3 = polyfit(x32Fit(:),histAvaLifetime2Fit(:),1);
    p3Eval = 10^p3(2).*(x3).^p3(1);
    %% log binning
%     maxaVaLifetimeLog = ceil(log10(maxLifetime));
%     x3Log = logspace(0, maxaVaLifetimeLog, maxaVaLifetimeLog/dtLog);
%     histAvaLifetimeLog = histc(aVaLifetime,x3Log);
%     binSizes = [1 x3Log(2:end)-x3Log(1:end-1)]';
% %     histAvaLifetimeLogNorm = (histAvaLifetimeLog(1:end-1)./binSizes)/numAva;
%     histAvaLifetimeLogNorm = (histAvaLifetimeLog./binSizes);
%     outliers3Log = histAvaLifetimeLog<th;
%     histAvaLifetimeLogFit = log10(histAvaLifetimeLogNorm(~outliers3Log));
%     x3LogFit = log10(x3Log(~outliers3Log));
%     p3Log = polyfit(x3LogFit(:),histAvaLifetimeLogFit(:),1);
%     p3LogEval = 10^p3Log(2).*(x3Log).^p3Log(1); 
    %%
    pl3 = 1e+5.*(x3).^(-2);
    %
    loglog(x3,histAvaLifetime,'k.-');    
    hold all
%     loglog(x3Log,histAvaLifetimeLogNorm','r.-');
    loglog(x3(~outliers3),p3Eval(~outliers3),'r--','LineWidth',2)
%     loglog(x3Log(~outliers3Log),p3LogEval(~outliers3Log),'r--','LineWidth',2)
    loglog(x3(3:end-3),pl3(3:end-3),'k-.','LineWidth',2)
    title('Lifetime')
    xlabel('lifetime (# bins)','FontSize',14,'FontName','arial')
%     ylabel('P(lifetime)','FontSize',14,'FontName','arial')
    ylabel('Frequency','FontSize',14,'FontName','arial')
%     legend('lin bin','log bin',['slope: ',num2str(p3(1))],['slope: ',num2str(p3Log(1))],'slope: -2')
    legend('data',['slope: ',num2str(p3(1))],'ref slope: -2');

    axis square
end