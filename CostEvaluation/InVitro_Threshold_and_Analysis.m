%% confronto tra sogliature 
clear all 
close all
%% Calcola Nlink,Ratio exc/Inh, TPR per un dato nexc,ninh
% calcola Le curve 3D per una sola matrice al variare di ninh e nexc

%% ---------scegliere cartella contenente la matrice da sogliare-------------
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
connRule=cell2mat(last(end));
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(find([net_folders.isdir]))-2;
net_folders = net_folders(find([net_folders.isdir]));
%% ------------- scegliere la matrice da confrontare-------------------------
for i=1:num_folder                   % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=5;
    repNet=dir;
    type{i}=string(net_folders(i+2).name);
    for k=1:4%numrepNet                     % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    temp_dir=dir;
    last=split(temp_dir(3).name,'_');
    date=cell2mat(last(1));
    cd('CrossCorrelation')
    CCfolder=pwd;

        %% ----------------------sogliatura--------------------------------
    nexc=[1];
    ninh=[2];

    [CC_meanstd,CC_cost,CC_bin_meanstd,CC_bin_cost,CCnlink,CCshuff] = ThresholdMatrixEvaluation(CCfolder,nexc,ninh);
    n=length(CC_bin_cost);
    CC=zeros(n,n,length(nexc)+length(nexc));
    CC(:,:,1)=CC_bin_meanstd;
    CC(:,:,2)=CC_bin_cost;
    CC(:,:,3)=weight_conversion(CCnlink,'binarize');
    CC(:,:,4)=weight_conversion(CCshuff,'binarize');

    C=zeros(n,n,length(nexc)+length(nexc));
    C(:,:,1)=CC_meanstd;
    C(:,:,2)=CC_cost;
    C(:,:,3)=CCnlink;
    C(:,:,4)=CCshuff;
    
    clear CC_bin_meanstd CC_bin_cost CC_cost CC_meanstd
    cd(tempFolder)
   
    %% ----------------------compute number of links-------------------------
        %ratio exc/inh
        link_ms_exc(k)=length(find(C(:,:,1)>0));
        link_ms_inh(k)=length(find(C(:,:,1)<0));
        link_cost_exc(k)=length(find(C(:,:,2)>0));
        link_cost_inh(k)=length(find(C(:,:,2)<0));
        link_nlink_exc(k)=length(find(C(:,:,3)>0));
        link_nlink_inh(k)=length(find(C(:,:,3)<0));
        link_shuff_exc(k)=length(find(C(:,:,4)>0));
        link_shuff_inh(k)=length(find(C(:,:,4)<0));
        ratio_cost(k)=link_cost_inh(k)/(link_cost_exc(k)+link_cost_inh(k))*100;
        ratio_nlink(k)=link_nlink_inh(k)/(link_nlink_exc(k)+link_nlink_inh(k))*100;
        ratio_shuff(k)=link_shuff_inh(k)/(link_shuff_exc(k)+link_shuff_inh(k))*100;
        ratio_ms(k)=link_ms_inh(k)/(link_ms_exc(k)+link_ms_inh(k))*100;
        ratio_inh= [ratio_ms; ratio_cost;ratio_nlink;ratio_shuff]';
     
    %% -----------------------  SWI ---------------------------------------
         tmpMS=CC(:,:,1);
         tmpCost=CC(:,:,2);
         tmpNlink=CC(:,:,3);
         tmpShuffling=CC(:,:,4);
         n = size(tmpMS,1);  % number of nodes
         m = sum(sum(tmpMS)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWms(k),~,~] = small_world_ness2(tmpMS,Lrand,CrandWS,1);
         n = size(tmpCost,1);  % number of nodes
         m = sum(sum(tmpCost)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWcost(k),~,~] = small_world_ness2(tmpCost,Lrand,CrandWS,1);
         n = size(tmpNlink,1);  % number of nodes
         m = sum(sum(tmpNlink)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWnlink(k),~,~] = small_world_ness2(tmpNlink,Lrand,CrandWS,1);
         n = size(tmpShuffling,1);  % number of nodes
         m = sum(sum(tmpShuffling)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWShuffle(k),~,~] = small_world_ness2(tmpShuffling,Lrand,CrandWS,1);
         SWI= [SWms; SWcost;SWnlink;SWShuffle]';
       
    %% ---------------------------- Modularity ----------------------------
         [~ ,Q_ms(k)] = modularity_dir(tmpMS);
         [~, Q_cost(k)] = modularity_dir(tmpCost);
         [~ ,Q_nlink(k)] = modularity_dir(tmpNlink);
         [~, Q_Shuffle(k)] = modularity_dir(tmpShuffling);
         Modularity = [Q_ms; Q_cost;Q_nlink;Q_Shuffle]';
    end
    cd(folder)
    save('ratio_inh','ratio_inh')
    save('SWI','SWI')
    save('Modularity','Modularity')
end
%% --------------------------- boxplot --------------------------
