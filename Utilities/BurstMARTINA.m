close all
clear all
%% ---------------------------------------------------------------------
nspikes = 3;
ISImax = 100;
mbr_thresh = 0.4;
IBIwin = 10;
IBIbin = 1;
MBR=zeros(3,20);
SpikeinBurst=zeros(3,20);
BurstDur=zeros(3,20);
IBI=zeros(3,20);
%%
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(dir)-2;
for i = 5%1:num_folder
    cd(net_folders(i+2).name);
    connRule= net_folders(i+2).name;
    type_folders = dir;
    num_type_folder=length(dir)-2;
    topology_folder=pwd;
    for j = 1:num_type_folder
        cd(string(j)) 
        tempFolder=pwd;
        cd('Electrophysiological_Analysis')
        elettro_folder=pwd;
        cd('01_PeakDetectionMAT_files_500neurons')
        peak_folder=pwd;
        %[exp_num] = BurstDetection (peak_folder, nspikes, ISImax, mbr_thresh, 1000, 500, IBIwin, IBIbin); 
        cd(elettro_folder)
        cd('01_BurstAnalysis')
        cd('01_MeanStatReportBURST')
        load('BurstStat_ptrain_All1_1.mat')
        cd(elettro_folder)
        cd('01_BurstAnalysis')
        cd('01_MeanStatReportSPIKEinBURST')
        load('SpikeStat_ptrain_All1_1.mat')
        if i==5
              RND_BS(j).MBR = double(BurstStatistics);
        elseif i==2
              SF_BS(j).MBR = double(BurstStatistics);
        elseif i==3
              SW_BS(j).MBR = double(BurstStatistics);
        end
        
        cd(topology_folder)
        close all
    end

   cd(folder)
end
save('RND_BS','RND_BS')
save('SF_BS','SF_BS')
save('SW_BS','SW_BS')
%% boxplot MFR
figure
X = categorical({'Random','Small-World','Scale-Free'});
X = reordercats(X,{'Random','Small-World','Scale-Free'});
Y = mean(MBR');
b=bar(X,Y);
b.FaceColor = 'flat';
b.CData(1,:) = [1 1 1].*0.8;
b.CData(2,:) = [1 1 1].*0.6;
b.CData(3,:) = [1 1 1].*0.3;
xlabel('Neurons')
ylabel('MBR [burst/min]')
title('MBR');
pos_err = std(MBR',0,1);
hold on 
er = errorbar(X,Y,pos_err); 
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 1;
hold off
%%
figure
X = categorical({'Random','Small-World','Scale-Free'});
X = reordercats(X,{'Random','Small-World','Scale-Free'});
Y = mean(IBI');
b=bar(X,Y);
b.FaceColor = 'flat';
b.CData(1,:) = [1 1 1].*0.8;
b.CData(2,:) = [1 1 1].*0.6;
b.CData(3,:) = [1 1 1].*0.3;
xlabel('Neurons')
ylabel('IBI [sec]')
title('IBI');
pos_err = std(IBI',0,1);
hold on 
er = errorbar(X,Y,pos_err); 
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 1;
hold off

figure
X = categorical({'Random','Small-World','Scale-Free'});
X = reordercats(X,{'Random','Small-World','Scale-Free'});
Y = mean(PercRndSpike');
b=bar(X,Y);
b.FaceColor = 'flat';
b.CData(1,:) = [1 1 1].*0.8;
b.CData(2,:) = [1 1 1].*0.6;
b.CData(3,:) = [1 1 1].*0.3;
xlabel('Neurons')
ylabel('Random Spike [%]')
title('Perc. Random Spike');
pos_err = std(PercRndSpike',0,1);
hold on 
er = errorbar(X,Y,pos_err); 
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 1;
hold off


figure
X = categorical({'Random','Small-World','Scale-Free'});
X = reordercats(X,{'Random','Small-World','Scale-Free'});
Y = mean(BurstDur');
b=bar(X,Y);
b.FaceColor = 'flat';
b.CData(1,:) = [1 1 1].*0.8;
b.CData(2,:) = [1 1 1].*0.6;
b.CData(3,:) = [1 1 1].*0.3;
xlabel('Neurons')
ylabel('BurstDur [ms]')
title('BurstDur');
pos_err = std(BurstDur',0,1);
hold on 
er = errorbar(X,Y,pos_err); 
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 1;
hold off


