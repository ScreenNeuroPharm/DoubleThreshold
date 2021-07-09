clear all 
close all
%% Calcola Nlink,Ratio exc/Inh, TPR per un dato nexc,ninh
% calcola Le curve 3D per una sola matrice al variare di ninh e nexc

%% ---------scegliere cartella contenente la matrice da sogliare-------------
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
connRule='SF';
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(find([net_folders.isdir]))-2;
net_folders = net_folders(find([net_folders.isdir]));
%% ------------- scegliere la matrice da confrontare-------------------------
for i=1:num_folder                   % cicli per tipo di net
    cd(net_folders(i+2).name) 
    type{i}=string(net_folders(i+2).name);
    tempFolder=pwd;
    numrepNet=3;
    repNet=dir;
    for k=2:numrepNet                     % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    temp_dir=dir;
    last=split(temp_dir(3).name,'_');
    date=cell2mat(last(1));
    cd(strcat(date,'_CrossCorrelation'))
    CCfolder=pwd;
%     cd('Topological_Analysis')
%     load('ConnectivityMatrix_900_sec.mat')
%     cd(start_folder)
%     cd(net_folders(i+2).name)
%     cd(repNet(k+2).name)
%     cd('Electrophysiological_CrossCorrelation');
%     CCfolder=pwd;
%     AD_bin=AdjacencyMatrix;
%     AD_bin(AD_bin~=0)=1;
%     Nlink(1,k)=sum(AD_bin(:));
        %% ----------------------sogliatura--------------------------------
    nexc=[1];
    ninh=[2];
    
for ii=1:length(nexc)
    CC(:,:,ii)=importdata(strcat("TCM_Binary_nexc=",string(nexc(ii)),"_ninh=",string(ninh(ii)),".mat"));
    CC(:,:,ii+length(nexc))=importdata(strcat("TCM_Binary_Cost",string(nexc(ii)),"_",string(ninh(ii)),".mat"));
    C(:,:,ii)=importdata(strcat("TCM_nexc=",string(nexc(ii)),"_ninh=",string(ninh(ii)),".mat"));
    C(:,:,ii+length(nexc))=importdata(strcat("TCM_Cost",string(nexc(ii)),"_",string(ninh(ii)),".mat"));
    C(:,:,3)=importdata("TCM_Nlink.mat");
    CC(:,:,3)=importdata('TCM_Binary_Nlink.mat');
    C(:,:,4)=importdata("TCM_Shuffle.mat");
    CC(:,:,4)=importdata('TCM_Binary_Shuffle.mat');
    
end   

   cd(tempFolder)
  
        s(1)="nexc=1_ninh=1";
        s(2)="nexc=1_ninh=1";
        s(3)="nexc=1 ninh=1";
        s(4)="nexc=1 ninh=1";
        tmpMS = C(:,:,1);
        tmpCost = C(:,:,2);
        tmpNlink =  C(:,:,3);
        tmpShuffling =  C(:,:,4);
        

      
         
            %--------------------Ms Deg Dist---------------------------------------
            [h, FitParameters_ms(:,i,k)] = DistribDegreeExcInhAB(tmpMS,'SF');
            figure(h)
            title(strcat('M-S ',s(3),' Degree Distribution'))
            saveas(h,strcat('DegDist HardThreshold ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_',string(k),'_ms_',s(1),'.jpg'),'jpeg');
            [hub_ms{k},n_ms(i,k)]=findHUB(tmpMS);
            %--------------------Double threshold Deg Dist---------------------------------------
            [h, FitParameters_norm(:,i,k)] = DistribDegreeExcInhAB(tmpCost,'SF');
            figure(h)
            title(strcat('Double Threshold Degree Distribution'))
            saveas(h,strcat('DegDist DoubleThresh ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_DoubleThresh_',string(k),'.jpg'),'jpeg');
            [hub_ddt{k},n_ddt(i,k)]=findHUB(tmpCost);
            %------------------------Nlink--------------------------------
            [h, FitParameters_nlink(:,i,k)] = DistribDegreeExcInhAB( tmpNlink ,'SF');
            figure(h)
            title(strcat('Nlink Degree Distribution'))
            saveas(h,strcat('DegDist DensityBasedTH ',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_Nlink_',string(k),'.jpg'),'jpeg');
            [hub_nlink{k},n_nlink(i,k)]=findHUB(tmpNlink );
            %-----------------------Shuffling------------------------------
            [h, FitParameters_shuffling(:,i,k)] = DistribDegreeExcInhAB( tmpShuffling ,'SF');
            figure(h)
            title(strcat('Shuffling Degree Distribution'))
            saveas(h,strcat('DegDist_Shuffling',string(k),'.fig'),'fig');
            saveas(h,strcat('DegDist_Shuffling',string(k),'.jpg'),'jpeg');
            [hub_shuffling{k},n_shuffling(i,k)]=findHUB(tmpShuffling);
            

        close all


        
    end
     cd(folder)
end

 
%%
for i=1:3
        a=figure
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        Y = squeeze([FitParameters_ms(2,i,:)  FitParameters_nlink(2,i,:) FitParameters_norm(2,i,:)  FitParameters_shuffling(2,i,:)]);
        b=boxplot(abs(Y'),X);
        set(b,{'linew'},{2})
        set(gca,'linew',2);         
        xlabel('Threshold Method')
        ylabel('R^2 %')
        title(strcat("Fitting Degree Distribution",type{i}));
        ylim([ 0 1]);      
        box off
        savefig(a,strcat("DEG_",type{i},".fig"));
        saveas(a,strcat("DEG_",type{i},'.jpg'),'jpeg');
       [~,~,stats]=anova1(Y',X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.05);
       figure(h)
       title('SWI')
       savefig(h,"ANOVA_DEG.fig");
end
%% 
for i=1:3
        a=figure
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        Y = squeeze([n_ms(i,:)'  n_nlink(i,:)' n_ddt(i,:)'  n_shuffling(i,:)']);
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2);         
        xlabel('Threshold Method')
        ylabel('#')
        title(strcat("Number of Hubs ",type{i}));
        %ylim([-1 0]);
        box off
        savefig(a,strcat("HUB_",type{i},".fig"));
        saveas(a,strcat("HUB_",type{i},'.jpg'),'jpeg');
       [~,~,stats]=anova1(Y,X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.05);
       figure(h)
       title('SWI')
       savefig(h,"ANOVA_HUB.fig");
end