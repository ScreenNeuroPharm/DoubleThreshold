clear all 
close all
clc
startFolder="C:\Users\alessio\Desktop\tesi\Data\18DIVTRIS\SimNetwork\SHUFFLING\RND\first\1\Electrophysiological_Analysis\01_BurstAnalysis\01_MeanStatReportBURST";
x=split(startFolder,'\');

s={'RND','SW','SF'};
for i=1:3           % cycle over the network type 
    x(10)=string(s(i));
    for n=1:6       % cycle over the folders
    x(12)=string(n);
    Folder=join(x,'\');
    cd(Folder)
    if strcmp(s(i),"RND") RNDburst(n)=load('BurstStat_ptrain_All1_1.mat');
    elseif strcmp(s(i),"SW") SWburst(n)=load('BurstStat_ptrain_All1_1.mat');
    elseif strcmp(s(i),"SF") SFburst(n)=load('BurstStat_ptrain_All1_1.mat'); 
    end
    
    end 
end
%% boxplot 
% number of bursting neurons
for n=1:6   % Random
    tmp=RNDburst(n).BurstStatistics;
    tmp=tmp(:,1);
    RNDinhBurstingNeurons(n)=length(find(double(tmp)>400));
    RNDexcBurstingNeurons(n)=length(find(double(tmp)<400));
end 
for n=1:6   % SW
    tmp=SWburst(n).BurstStatistics;
    tmp=tmp(:,1);
    SWinhBurstingNeurons(n)=length(find(double(tmp)>400));
    SWexcBurstingNeurons(n)=length(find(double(tmp)<400));
end 
for n=1:6   % SF
    tmp=SFburst(n).BurstStatistics;
    tmp=tmp(:,1);
    SFinhBurstingNeurons(n)=length(find(double(tmp)>400));
    SFexcBurstingNeurons(n)=length(find(double(tmp)<400));
end 
%  MBR
for n=1:6   % Random
    tmp=RNDburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,3));
    RNDinhMBR(n,1)=mean(tmp(inh));
    RNDinhMBR(n,2)=std(tmp(inh));
    RNDexcMBR(n,1)=mean(tmp(exc));
    RNDexcMBR(n,2)=std(tmp(exc));    
end 
for n=1:6   % SW
 tmp=SWburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,3));
    SWinhMBR(n,1)=mean(tmp(inh));
    SWinhMBR(n,2)=std(tmp(inh));
    SWexcMBR(n,1)=mean(tmp(exc));
    SWexcMBR(n,2)=std(tmp(exc));    
end 
for n=1:6   % SF
    tmp=SFburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,3));
    SFinhMBR(n,1)=mean(tmp(inh));
    SFinhMBR(n,2)=std(tmp(inh));
    SFexcMBR(n,1)=mean(tmp(exc));
    SFexcMBR(n,2)=std(tmp(exc));    
end 

%NumSpikeInBurst
for n=1:6   % Random
    tmp=RNDburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,5));
    RNDinhSpikeInBurst(n,1)=mean(tmp(inh));
    RNDinhSpikeInBurst(n,2)=std(tmp(inh));
    RNDexcSpikeInBurst(n,1)=mean(tmp(exc));
    RNDexcSpikeInBurst(n,2)=std(tmp(exc));    
end 
for n=1:6   % SW
 tmp=SWburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,5));
    SWinhSpikeInBurst(n,1)=mean(tmp(inh));
    SWinhSpikeInBurst(n,2)=std(tmp(inh));
    SWexcSpikeInBurst(n,1)=mean(tmp(exc));
    SWexcSpikeInBurst(n,2)=std(tmp(exc));    
end 
for n=1:6   % SF
    tmp=SFburst(n).BurstStatistics;
    ind=tmp(:,1);
    inh=find(double(ind)>400);
    exc=find(double(ind)<400);
    tmp=double(tmp(:,5));
    SFinhSpikeInBurst(n,1)=mean(tmp(inh));
    SFinhSpikeInBurst(n,2)=std(tmp(inh));
    SFexcSpikeInBurst(n,1)=mean(tmp(exc));
    SFexcSpikeInBurst(n,2)=std(tmp(exc));    
end 

%% Mean and Std of the number of bursting neurons
RNDMeanBurstingNeuron=mean(RNDexcBurstingNeurons+RNDinhBurstingNeurons);
RNDStdBurstingNeuron=std(RNDexcBurstingNeurons+RNDinhBurstingNeurons);

SWMeanBurstingNeuron=mean(SWexcBurstingNeurons+SWinhBurstingNeurons);
SWDStdBurstingNeuron=std(SWexcBurstingNeurons+SWinhBurstingNeurons);

SFMeanBurstingNeuron=mean(SFexcBurstingNeurons+SFinhBurstingNeurons);
SFStdBurstingNeuron=std(SFexcBurstingNeurons+SFinhBurstingNeurons);

BurstingNeuronsTable=table([RNDMeanBurstingNeuron SWMeanBurstingNeuron SFMeanBurstingNeuron]',[RNDStdBurstingNeuron...
     SWDStdBurstingNeuron SFStdBurstingNeuron]','VariableNames',{'Mean','Std'},'RowNames',{'RND','SW','SF'});
BurstingNeuronsTable.Properties.Description = 'Mean and Std of the number of bursting neurons';
%% MBR
MBRTable = table([mean(RNDexcMBR(:,1)) mean(SWexcMBR(:,1)) mean(SFexcMBR(:,1))]',...
     [mean(RNDexcMBR(:,2)) mean(SWexcMBR(:,2)) mean(SFexcMBR(:,2))]',...
     [mean(RNDinhMBR(:,1)) mean(SWinhMBR(:,1)) mean(SFinhMBR(:,1))]',...
     [mean(RNDinhMBR(:,2)) mean(SWinhMBR(:,2)) mean(SFinhMBR(:,2))]',...
     'VariableNames',{'Exc Mean','Exc Std','Inh Mean','Inh Std'},...
     'RowNames',{'RND','SW','SF'});
%% SpikeInBurst
SpikeInBurstTable = table([mean(RNDexcSpikeInBurst(:,1)) mean(SWexcSpikeInBurst(:,1)) mean(SFexcSpikeInBurst(:,1))]',...
     [mean(RNDexcSpikeInBurst(:,2)) mean(SWexcSpikeInBurst(:,2)) mean(SFexcSpikeInBurst(:,2))]',...
     [mean(RNDinhSpikeInBurst(:,1)) mean(SWinhSpikeInBurst(:,1)) mean(SFinhSpikeInBurst(:,1))]',...
     [mean(RNDinhSpikeInBurst(:,2)) mean(SWinhSpikeInBurst(:,2)) mean(SFinhSpikeInBurst(:,2))]',...
     'VariableNames',{'Exc Mean','Exc Std','Inh Mean','Inh Std'},...
     'RowNames',{'RND','SW','SF'});