close all
clear all

folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
connRule=cell2mat(last(end));
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(dir)-2;
%% ------------- scegliere la matrice da confrontare-------------------------
for i=2 %3:num_folder                     % cicli per tipo di net
    cd(string(i)) 
    tempFolder=pwd;
    cd('Electrophysiological_Analysis')
    cd('01_PeakDetectionMAT_files_500neurons')
    peak_folder=pwd;
    % -------------------------- MFR ------------------------------
      mfr_thresh = 0.001;
    KernelWidth = [20 900]; % (ms) No more than 2!!!!
    if length(KernelWidth) > 2
        KernelWidth = KernelWidth(1:2);
    end
    undersamplingFactor = 1;
    MFR(peak_folder, 500, 1000, mfr_thresh);
    % ----------------------- BURST ANALISYS -----------------------
    nspikes = 4;
    ISImax = 100;
    mbr_thresh = 0.4;
    IBIwin = 10;
    IBIbin = 1;
    cd(peak_folder)
    [exp_num] = BurstDetection (peak_folder, nspikes, ISImax, mbr_thresh, 1000, 500, IBIwin, IBIbin); 
    cd(folder)

end
%%
for i=1:num_folder
    cd(string(i)) 
    cd('Electrophysiological_Analysis')
    tempFolder=pwd;
    cd('01_SpikeAnalysis')
    cd('01_MeanFiringRate - thresh_0.001')
    load('MFR_global');
    mfr_mean(i,:)=MFR_global.MFR_mean;
    cd(tempFolder);
    cd('01_BurstAnalysis')
    cd('01_MeanStatReportBURST')
    load('BurstStat_ptrain_All1_1.mat')
    MBR(i)=mean(double(BurstStatistics(:,3)));
    SpikeinBurst(i)=mean(double(BurstStatistics(:,5)));
    BurstDur(i)=mean(double(BurstStatistics(:,7)));
    IBI(i)=mean(double(BurstStatistics(:,9)));
    cd(folder)
end
%% boxplot MFR
figure
X = categorical({'Total','Excitatory','Inhibitory'});
X = reordercats(X,{'Total','Excitatory','Inhibitory'});
Y = mean(mfr_mean);
bar(X,Y,'FaceColor',[0.7 0.7 0.7])
xlabel('Neurons')
ylabel('MFR [spike/sec]')
title('MFR');
pos_err = std(mfr_mean,0,1);
hold on 
er = errorbar(X,Y,pos_err); 
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 1;
hold off

