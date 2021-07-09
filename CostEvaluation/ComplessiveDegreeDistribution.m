%% confronto tra sogliature SOLO CON NINH=2
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
    %num_folder -1                         % cicli per tipo di net
    cd(net_folders(3).name) 
    tempFolder=pwd;
    numrepNet=6;  %length(dir)-2;
    repNet=dir;
    n=500;
    CMht=zeros(n,n,numrepNet);
    CMdt=zeros(n,n,numrepNet);
    CMddt=zeros(n,n,numrepNet);
    CMsh=zeros(n,n,numrepNet);
    for k=1:numrepNet                         % cicli per ripetizione del tipo di net
    
    cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_900_sec.mat')
    load('ConnectivityMatrix_1_sec.mat')
    cd(start_folder)
    cd(net_folders(3).name)
    cd(repNet(k+2).name)
    cd('Electrophysiological_CrossCorrelation');
    CCfolder=pwd;
    AD_bin=AdjacencyMatrix;
    AD(:,:,k)=AdjacencyMatrix;
    AD_bin(AD_bin~=0)=1;
    Nlink(1,k)=length(find(AD_bin~=0));
    
    AD_bin_0=AdjacencyMatrix_0;
    AD_bin_0(AD_bin_0~=0)=1;
    n=length(AD_bin);

    %% ----------------------sogliatura------------------------------------
    nexc=[1];
    ninh=[2];
    CMht(:,:,k)=importdata(strcat("TCM_nexc=",string(nexc),"_ninh=",string(ninh),".mat"));
    CMddt(:,:,k)=importdata(strcat("TCM_Cost",string(nexc),"_",string(ninh),".mat"));
    CMdt(:,:,k)=importdata('TCM_Nlink.mat');
    CMsh(:,:,k)=importdata('TCM_Shuffle.mat');

 cd(tempFolder)
%---------------------Struct Deg Dist----------------------------------
  
%-----------------------struct HUB-----------------------------------------
if strcmp(connRule,'SF')
 [hub_exc,Hub_struct(k)]=findHUB(AdjacencyMatrix);
  
end
    end
%% -------------------degree distribution----------------------------------  
      
    [h, FitParameters,Y,X,plotFittedData] = DistribDegreeExcInhAB_structural(AD,connRule);
    figure(h)
    title('Structural Degree Distribution')
    saveas(h,strcat('DegreeDistribution_Struct',string(k),'.fig'),'fig');
    saveas(h,strcat("DegreeDistribution_Struct",string(k)),'jpeg');
     s(1)="nexc=1_ninh=2";
     s(2)="nexc=1_ninh=2";
     s(3)="nexc=1 ninh=2";
     s(4)="nexc=1 ninh=2";
     ind=0;
     
     
 %%    
       if strcmp(connRule,'RND')
           Y=[];
           plotFittedData=[];
       end
     
            ind=ind+1;
            %--------------------Ms Deg Dist---------------------------------------
            [h, FitParameters_HT] = DistribDegreeExcInhAB(CMht,connRule,Y,plotFittedData);
            figure(h)
            title(strcat('M-S ',s(ind+2),' Degree Distribution'))
            saveas(h,strcat('DegDist HardThreshold ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_',string(k),'_ms_',s(ind),'.jpg'),'jpeg');
            %[hub_ms{k},n_ms(k)]=findHUB(C(:,:,ii));
            %--------------------Double threshold Deg Dist---------------------------------------
            [h, FitParameters_DDT] = DistribDegreeExcInhAB(CMddt,connRule,Y,plotFittedData);
            figure(h)
            title(strcat('Double Threshold Degree Distribution'))
            saveas(h,strcat('DegDist DoubleThresh ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_DoubleThresh_',string(k),'.jpg'),'jpeg');
            %[hub_ddt{k},n_ddt(k)]=findHUB(C(:,:,ii+length(nexc)));
            %------------------------Nlink--------------------------------
            [h, FitParameters_density] = DistribDegreeExcInhAB(CMdt,connRule,Y,plotFittedData);
            figure(h)
            title(strcat('Nlink Degree Distribution'))
            saveas(h,strcat('DegDist DensityBasedTH ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_Nlink_',string(k),'.jpg'),'jpeg');
            %[hub_nlink{k},n_nlink(k)]=findHUB(C(:,:,3));
            %-----------------------Shuffling------------------------------
            [h, FitParameters_shuffling] = DistribDegreeExcInhAB(CMsh,connRule,Y,plotFittedData);
            figure(h)
            title(strcat('Shuffling Degree Distribution'))
            saveas(h,strcat('DegDist_Shuffling',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_Shuffling',string(k),'.jpg'),'jpeg');
            %[hub_shuffling{k},n_shuffling(k)]=findHUB(C(:,:,4));
            
            %% --------------HUB DETECTION----------------
            
            if strcmp(connRule,'SF')
                for k=1:6
                   
                    [~,hub_ht(k)]=findHUB(CMht(:,:,k));
                    [~,hub_DDT(k)]=findHUB(CMddt(:,:,k));
                    [~,hub_DT(k)]=findHUB(CMdt(:,:,k));
                    [~,hub_SH(k)]=findHUB(CMsh(:,:,k));
                end
            end
        close all

%boxplot([hub_DDT',hub_DT',hub_ht',hub_SH',Hub_struct']);