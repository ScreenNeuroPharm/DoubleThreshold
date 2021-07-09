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
for i=1:num_folder                          % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=length(dir)-2;
    repNet=dir;
    for k=1:numrepNet                            % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_600_sec.mat')
    cd(start_folder)
    cd(net_folders(i+2).name)
    cd(repNet(k+2).name)
    cd('Electrophysiological_CrossCorrelation');
    CCfolder=pwd;
    AD_bin=AdjacencyMatrix;
    AD_bin(AD_bin~=0)=1;
    Nlink(1,k)=length(find(AD_bin~=0));
    StructWeigthTOT=AdjacencyMatrix(AdjacencyMatrix~=0);
    TotStructProf=histcounts(weight_conversion(StructWeigthTOT,'normalize'),100);
    f=figure;
    histogram(weight_conversion(StructWeigthTOT,'normalize'),100);
    title('structural weight distribution')
    saveas(f,'WeightDistribution_Struct.fig','fig');
    StructWeigthEXC=AdjacencyMatrix(AdjacencyMatrix>0);
    ExcStructProf=histcounts(StructWeigthEXC-mean(StructWeigthEXC),50);
    StructWeigthINH=AdjacencyMatrix(AdjacencyMatrix<0);
    InhStructProf=histcounts(weight_conversion(StructWeigthINH,'normalize'),100);
    
    [h, FitParameters(:,:,1,k)] = DistribDegreeExcInhAB(AdjacencyMatrix,'RND');
    saveas(h,'DegreeDistribution_Struct.fig','fig');
     if strcmp(connRule,"SF")
             [h, FitParameters(:,1,k)] = DistribDegreeExcInhAB(AdjacencyMatrix,'SF');
                [id, od, deg] = degrees_dir(AdjacencyMatrix);
                thres = mean(deg) + std(deg);
                HubStruct = string(find(deg > thres));
                NumHub(1,k)=length(HubStruct);
                
                thres_id = mean(id) + std(id);
                HubStructIN = string(find(id > thres));
                NumHubIN(1,k)=length(HubStructIN);
                
                thres_od = mean(od) + std(od);
                HubStructOUT = string(find(od > thres));
                NumHubOUT(1,k)=length(HubStructOUT);
     else
            % [h, FitParameters(:,1)] = DistribDegreeExcInh(AdjacencyMatrix,'RND');
     end
    %% sogliatura
    nexc=[1 1];
    ninh=[1 2];
    
    [CC_meanstd,CC_cost,CC_bin_meanstd,CC_bin_cost] = ThresholdMatrixEvaluation(CCfolder,nexc,ninh,1,syn);
    n=length(CC_bin_cost);
    CC=zeros(n,n,length(nexc)+length(nexc));
    CC(:,:,1:length(nexc))=CC_bin_meanstd;
    CC(:,:,length(nexc)+1:end)=CC_bin_cost;

    C=zeros(n,n,length(nexc)+length(nexc));
    C(:,:,1:length(nexc))=CC_meanstd;
    C(:,:,length(nexc)+1:end)=CC_cost;
    clear CC_bin_meanstd CC_bin_cost CC_cost CC_meanstd
    %% compute parameters
    n = size(AD_bin,1);  % number of nodes
    m = sum(sum(AD_bin)); %number of edges directed network
    [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
    [SW(1,k),Ccoeff(1,k),PL(1,k)] = small_world_ness2(AD_bin,Lrand,CrandWS,1); 
   

    for j=1:length(nexc)*2
          tmp=C(:,:,j);
          tmp_bin=CC(:,:,j);
         %----------------------SWI----------------------------------------
         n = size(tmp,1);  % number of nodes
         m = sum(sum(tmp_bin)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SW(j+1,k),Ccoeff(j+1,k),PL(j+1,k)] = small_world_ness2(tmp_bin,Lrand,CrandWS,1);     
         %---------------------Weight distribution-------------------------
          FunctWeigthTOT=tmp(tmp~=0);
          TotFunctProf=histcounts(weight_conversion(FunctWeigthTOT,'normalize'),100);
          figure 
          f=histogram(weight_conversion(FunctWeigthTOT,'normalize'),100);
          FunctWeigthEXC=tmp(tmp>0);
          ExcFunctProf=histcounts(FunctWeigthEXC-mean(FunctWeigthEXC),50);
          FunctWeigthINH=tmp(tmp<0);
          InhFunctProf=histcounts(weight_conversion(FunctWeigthINH,'normalize')-mean(weight_conversion(FunctWeigthINH,'normalize')),100);
          D(j,k)=rms(ExcFunctProf - ExcStructProf)/rms(ExcStructProf);       % RMS
          %--------------------N links-------------------------------------
          Nlink(j+1,k)=length(find(tmp(tmp~=0)));       
          %-----------------Degree and weights distribution---------------------------
            if  strcmp(connRule,"RND")
                [h, FitParameters(:,:,j+1,k)] = DistribDegreeExcInhAB(tmp,connRule);
                if j==1
                    title('ms nexc=1 ninh=1')
                    saveas(h,'DegreeDistribution_MS1.fig','fig');
                    f=figure;
                    histogram(weight_conversion(FunctWeigthTOT,'normalize'),100);
                    title('ms nexc=1 ninh=1')
                    saveas(f,'WeightDistribution_MS2.fig','fig');
                elseif j==2
                    title('ms nexc=1 ninh=2')
                    saveas(h,'DegreeDistribution_MS2.fig','fig');
                   f=figure;
                    histogram(weight_conversion(FunctWeigthTOT,'normalize'),100);
                    title('MS nexc=1 ninh=2')
                    saveas(f,'WeightDistribution_MS22.fig','fig');
                elseif j==3
                     title('COST nexc=1 ninh=1')
                     saveas(h,'DegreeDistribution_Cost1.fig','fig');
                    f=figure;
                    histogram(weight_conversion(FunctWeigthTOT,'normalize'),100);
                    title('COST nexc=1 ninh=1')
                    saveas(f,'WeightDistribution_COST1.fig','fig');
                else
                    title('COST nexc=1 ninh=2')
                    saveas(h,'DegreeDistribution_Cost2.fig','fig'); 
                    f=figure;
                    histogram(weight_conversion(FunctWeigthTOT,'normalize'),100);
                    title('COST nexc=1 ninh=2')
                    saveas(f,'WeightDistribution_COST2.fig','fig');
                end
            else
                 [h, FitParameters(:,j+1,k)] = DistribDegreeExcInhAB(tmp,connRule);
                 %saveas(h,'DegreeDistribution.fig','fig');
            end
        %-------find the diffences in the second gaussian------------------
        load('DelayMatrix_ms.mat');
        meanDegStruct=squeeze(FitParameters(2,1,end,k));
        stdDegStruct=squeeze(FitParameters(3,1,end,k));
        [Ideg,~,~]=degrees_dir(tmp);
        highDegNeur=find(Ideg>meanDegStruct+stdDegStruct);
        lowDegNeur=setdiff([1:120],highDegNeur);
       if ~isempty(highDegNeur)
        figure
        tmphigh=tmp(highDegNeur,highDegNeur);
        histogram(tmphigh(tmphigh~=0));
        hold on
        tmplow=tmp(lowDegNeur,lowDegNeur);
        histogram(tmplow(tmplow~=0))
        legend('high degree','low degree')
         
        figure
        histogram(Delaymatrix_ms(highDegNeur,highDegNeur))
        hold on
        histogram(Delaymatrix_ms(lowDegNeur,lowDegNeur))
        legend('high degree','low degree')
       end
        %--------------------------hub detection-----------------------------
          if  strcmp(connRule,"SF")
                [id, od, deg] = degrees_dir(CC(:,:,j));
                thres_tot = mean(deg) + std(deg);
                thres_in = mean(id) + std(id);
                thres_out = mean(od) + std(od);
                Hub_tot =string(find(deg > thres_tot));
                Hub_id =string(find(id > thres_in));
                Hub_od =string(find(od > thres_out));
                NumHub(j+1,k)=length(Hub_tot);
                NumHubIN(j+1,k)=length(Hub_id);
                NumHubOUT(j+1,k)=length(Hub_od);
                n=0;
                for ii=1:length(Hub_tot)
                    n=n+length(find(strcmp(Hub_tot(ii),HubStruct)==1));
                end
                trpHub(j,k)=n./length(HubStruct);
                n=0;
                for ii=1:length(Hub_id)
                    n=n+length(find(strcmp(Hub_id(ii),HubStructIN)==1));
                end
                trpHubIN(j,k)=n./length(HubStructIN);
                n=0;
                for ii=1:length(Hub_od)
                    n=n+length(find(strcmp(Hub_od(ii),HubStructOUT)==1));
                end
                trpHubOUT(j,k)=n./length(HubStructOUT);
          end
    end
    cd(tempFolder)
    end
    close all
    cd(start_folder)
    cd(net_folders(i+2).name) 
    mkdir('EvaluationCost');
    cd('EvaluationCost');
%%
    %------------------------ saving phase----------------------------
    fig=figure(1);
    boxplot(D');
    title(strcat('Norm profile Distance (deg=',num2str(net_folders(i+2).name),')'));
    xticklabels({'MS 1','MS 2','COST 1','COST 2'})
    ylabel('RMS distance')
    saveas(fig,'Norm_profile_Distance','fig')
   
    fig=figure(2);
    boxplot(SW');
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('SWI ( deg=',num2str(net_folders(i+2).name),')'));
    ylabel('SWI')
    saveas(fig,'SWI','fig')
    
    fig=figure(5);
    boxplot(Nlink')
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Number of linkS (deg=',num2str(net_folders(i+2).name),')'));
    saveas(fig,'Nlink','fig')
    ylabel('Number of links')
    %----------------------------Fitting R2--------------------------------
    fig=figure(10);
    tempBoxR2=zeros(5);
    tempBoxR2=squeeze(FitParameters(4,:,:,:));
    tempBoxR2_tot=squeeze(tempBoxR2(1,:,:))';
    tempBoxR2_exc=squeeze(tempBoxR2(2,:,:))';
    tempBoxR2_inh=squeeze(tempBoxR2(3,:,:))';
    boxplot(tempBoxR2_tot)
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('R2 TOTALE (deg=',num2str(net_folders(i+2).name),')'));
    saveas(fig,'R2_tot','fig')
    ylabel('R2')
    
%     fig=figure(11);
%     boxplot(tempBoxR2_exc)
%     xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
%     title(strcat('R2 EXC (deg=',num2str(net_folders(i+2).name),')'));
%     saveas(fig,'R2_exc','fig')
%     ylabel('R2 exc')
%     
%      fig=figure(12);
%     boxplot(tempBoxR2_inh)
%     xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
%     title(strcat('R2 INH (deg=',num2str(net_folders(i+2).name),')'));
%     saveas(fig,'R2_inh','fig')
%     ylabel('R2 inh')
    %--------------Fitting b ( mean value of fitted gaussian) -------------
    fig=figure(20);
    tempBoxB=zeros(5);
    tempBoxB=squeeze(FitParameters(2,:,:,:));
    tempBoxB_tot=squeeze(tempBoxB(1,:,:))';
    tempBoxB_exc=squeeze(tempBoxB(2,:,:))';
    tempBoxB_inh=squeeze(tempBoxB(3,:,:))';
    boxplot(tempBoxB_tot)
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('B TOTALE (deg=',num2str(net_folders(i+2).name),')'));
    saveas(fig,'B_tot','fig')
    ylabel('B')
    
%     fig=figure(21);
%     boxplot(tempBoxB_exc)
%     xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
%     title(strcat('B EXC (deg=',num2str(net_folders(i+2).name),')'));
%     saveas(fig,'B_exc','fig')
%     ylabel('B exc')
%     
%      fig=figure(22);
%     boxplot(tempBoxB_inh)
%     xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
%     title(strcat('B INH (deg=',num2str(net_folders(i+2).name),')'));
%     saveas(fig,'B_inh','fig')
%     ylabel('B inh')
    
    
    %--------------SCALE FREE----------------------------------------------
    if strcmp(connRule,"SF")
    fig=figure(6);
    R2=squeeze(FitParameters(3,:,:))';
    boxplot(R2)
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Evaluation FITTING (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('R2')
    saveas(fig,'R2','fig')
    
    fig=figure(7);
    M=squeeze(FitParameters(1,:,:))';
    boxplot(M)
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Evaluation FITTING (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('M')
    saveas(fig,'M','fig')
    
    fig=figure(3);
    boxplot(NumHub')
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Number of Hubs total Degree (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('# of Hubs')
    saveas(fig,'HubsTotDeg','fig')
    
    fig=figure(4);
    boxplot(NumHubIN')
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Number of Hubs IN Degree (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('# of Hubs')
    saveas(fig,'HubsINDeg','fig')
    
    fig=figure(8);
    boxplot(NumHubOUT')
    xticklabels({'Struct','MS 1','MS 2','COST 1','COST 2'})
    title(strcat('Number of Hubs OUT Degree (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('# of Hubs')
    saveas(fig,'HubsOUTDeg','fig')
    
    fig=figure(9);
    boxplot(trpHub')
    xticklabels({'MS 1','MS 2','COST 1','COST 2'})
    title(strcat('True Positive Rate Tot Hub (deg=',num2str(net_folders(i+2).name),')'));
    ylabel('TRP TOT')
    saveas(fig,'TRP TOT','fig')

%     tabFitParameters=table(FitParameters(:,1),FitParameters(:,2),FitParameters(:,3),FitParameters(:,4),FitParameters(:,5)...
%         ,'RowNames',{'m','q','R2','m exc','q exc','R2 exc','m inh','q inh','R2 inh'}...
%         ,'VariableNames',{'Structural', 'MS ne=1 ni=1' ,'MS ne=1 ni=2', 'Cost ne=1 ni=1', 'Cost ne=1 ne=2'});
%     save('tabFitParameters','tabFitParameters');
%     save('FitParameters','FitParameters');
    end
    clear FitParameters
    cd(folder)
    close all
end
