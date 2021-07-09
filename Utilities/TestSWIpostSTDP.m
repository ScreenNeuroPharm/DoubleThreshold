%% confronto tra sogliature 
clear all 
close all

%---------scegliere cartella contenente la matrice da sogliare-------------
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
connRule=cell2mat(last(end));
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(dir)-2;
%------------- scegliere la matrice da confrontare-------------------------
for i=3  %num_folder-1                     % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=length(dir)-2;
    repNet=dir;
    for k=1:5 %numrepNet -1                        % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_600_sec.mat')
    load('ConnectivityMatrix_1_sec.mat')
    AdjacencyMatrix(AdjacencyMatrix~=0)=1;
    AdjacencyMatrix_0(AdjacencyMatrix_0~=0)=1;
    n = size(AdjacencyMatrix,1);  % number of nodes
    m = sum(sum(AdjacencyMatrix)); %number of edges directed network
    m_0 = sum(sum(AdjacencyMatrix_0)); %number of edges directed network
    [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
    [SW(k),~,~] = small_world_ness2(AdjacencyMatrix,Lrand,CrandWS,1);
    [Lrand_0,CrandWS_0] = NullModel_L_C(n,m_0,100,1);
    [SW_0(k),~,~] = small_world_ness2(AdjacencyMatrix_0,Lrand_0,CrandWS_0,1);
    cd(tempFolder)
    end 
    
end

boxplot([SW' SW_0'])
xticklabels({'Pre STDP','Post STDP'})
ylabel('SWI')
title('SWI pre e post STDP')
