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
    AD_bin(AD_bin~=0)=1;
    Nlink(1,k)=length(find(AD_bin~=0));
    
    AD_bin_0=AdjacencyMatrix_0;
    AD_bin_0(AD_bin_0~=0)=1;
   n=length(AD_bin);

    %% ----------------------sogliatura------------------------------------
    nexc=[1];
    ninh=[2];
 CC=zeros(n,n,length(nexc)+length(nexc));
 C=zeros(n,n,length(nexc)+length(nexc));
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
%---------------------Struct Deg Dist----------------------------------
 %   [h, FitParameters(:,k)] = DistribDegreeExcInhAB(AdjacencyMatrix,connRule);
%     figure(h)
%     title('Structural Degree Distribution')
%     saveas(h,strcat('DegreeDistribution_Struct',string(k),'.fig'),'fig');
%     saveas(h,strcat("DegreeDistribution_Struct",string(k)),'jpeg');
     s(1)="nexc=1_ninh=2";
     s(2)="nexc=1_ninh=2";
     s(3)="nexc=1 ninh=2";
     s(4)="nexc=1 ninh=2";
     ind=0;
%-----------------------struct HUB-----------------------------------------
% if strcmp(connRule,'SF')
%  [hub_exc,nhub_exc]=findHUB(AdjacencyMatrix);
%   
% end
%% -------------------degree distribution----------------------------------  
        for ii=1:length(nexc)
      
            ind=ind+1;
            %--------------------Ms Deg Dist---------------------------------------
            [h, FitParameters_ms(:,ii,k)] = DistribDegreeExcInhAB(C(:,:,ii),connRule);
            figure(h)
            title(strcat('M-S ',s(ind+2),' Degree Distribution'))
            %saveas(h,strcat('DegDist HardThreshold ',string(k),'.fig'),'fig');
            %saveas(h,strcat('DegDist_',string(k),'_ms_',s(ind),'.jpg'),'jpeg');
            [hub_ms{k},n_ms(k)]=findHUB(C(:,:,ii));
            %--------------------Double threshold Deg Dist---------------------------------------
            [h, FitParameters_norm(:,ii,k)] = DistribDegreeExcInhAB(C(:,:,ii+length(nexc)),connRule);
            figure(h)
            title(strcat('Double Threshold Degree Distribution'))
            %saveas(h,strcat('DegDist DoubleThresh ',string(k),'.fig'),'fig');
            %saveas(h,strcat('DegDist_DoubleThresh_',string(k),'.jpg'),'jpeg');
            [hub_ddt{k},n_ddt(k)]=findHUB(C(:,:,ii+length(nexc)));
            %------------------------Nlink--------------------------------
            [h, FitParameters_nlink(:,ii,k)] = DistribDegreeExcInhAB(C(:,:,3),connRule);
            figure(h)
            title(strcat('Nlink Degree Distribution'))
            %saveas(h,strcat('DegDist DensityBasedTH ',string(k),'.fig'),'fig');
            %saveas(h,strcat('DegDist_Nlink_',string(k),'.jpg'),'jpeg');
            [hub_nlink{k},n_nlink(k)]=findHUB(C(:,:,3));
            %-----------------------Shuffling------------------------------
            [h, FitParameters_shuffling(:,ii,k)] = DistribDegreeExcInhAB(C(:,:,4),connRule);
            figure(h)
            title(strcat('Shuffling Degree Distribution'))
            %saveas(h,strcat('DegDist_Shuffling',string(k),'.fig'),'fig');
            %saveas(h,strcat('DegDist_Shuffling',string(k),'.jpg'),'jpeg');
            [hub_shuffling{k},n_shuffling(k)]=findHUB(C(:,:,4));
            
            %% --------------HUB DETECTION----------------
%             if strcmp(connRule,'SF')
%                 [hub_ms,n_ms]=findHUB(C(:,:,ii));
%                 [hub_dt,n_dt]=findHUB(C(:,:,ii+length(nexc)));
%             end
        close all
        end

    end
close all
if strcmp(connRule,'SF')
    for i=1:length(nexc)
         %% fitting goodness SLOPE
        boxR2=[FitParameters_ms(1,i,:)  FitParameters_nlink(1,i,:)  FitParameters_norm(1,i,:) FitParameters_shuffling(1,i,:)];
        Y=squeeze(abs(boxR2))';
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        a=figure;
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
        title('SLOPE in Scale-Free Degree Dist')
        xlabel('Thresholding Method')
        ylabel('Slope')
        box off
        %savefig(a,strcat("SLOPE_",s(i),'.fig'));
        %saveas(a,strcat("SLOPE_",s(i),'.jpg'),'jpeg');
        [~,~,stats]=anova1(Y,X);
        [c,~,h,~] = multcompare(stats,'Alpha',0.05);
        figure(h)
        title(strcat('SLOPE SCALE-FREE DEGREE DISTRIBUTION-',s(i+2)))
        %savefig(h,strcat("ANOVA_SLOPE_DIST_",s(i),'.fig'));
   
        
       boxR2=[FitParameters_ms(2,i,:)  FitParameters_nlink(2,i,:)  FitParameters_norm(2,i,:) FitParameters_shuffling(2,i,:)];
        Y=squeeze(boxR2)';
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});  
        a=figure;
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
        title('R^2 fitting Scale-Free Degree Dist')
        xlabel('Thresholding Method')
        ylabel('R^2')
        box off
        hold on
        %savefig(a,strcat("FIT_",s(i),'.fig'));
        %saveas(a,strcat("FIT_",s(i),'.jpg'),'jpeg');
        [~,~,stats]=anova1(Y,X);
        [c,~,h,~] = multcompare(stats,'Alpha',0.05);
        figure(h)
        title(strcat('SLOPE SCALE-FREE DEGREE DISTRIBUTION-',s(i+2)))
        %savefig(h,strcat("ANOVA_DEG_DIST_",s(i),'.fig'));
        
           %% HUb boxplot
        boxHub=[n_ms' n_nlink'  n_ddt' n_shuffling'];
        Y=boxHub;
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        a=figure;
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
        title('Number of Hub')
        xlabel('Thresholding Method')
        ylabel('N of Hub')
        box off
        %savefig(a,strcat("HUB_",s(i),'.fig'));
        %saveas(a,strcat("HUB_",s(i),'.jpg'),'jpeg');
        [~,~,stats]=anova1(Y,X);
        [c,~,h,~] = multcompare(stats,'Alpha',0.05);
        figure(h)
        title(strcat('HUB SCALE-FREE DEGREE DISTRIBUTION-',s(i+2)))
        %savefig(h,strcat("ANOVA_HUB_",s(i),'.fig'));
    end
else
     for i=1:length(nexc)
        %% fitting goodness R^2
        boxR2=[FitParameters_ms(1,i,:)  FitParameters_nlink(1,i,:) FitParameters_norm(1,i,:) FitParameters_shuffling(1,i,:)];
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});       
        a=figure;
        b=boxplot(squeeze(boxR2)',X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
        title(strcat('FITTING NORMAL DEGREE DISTRIBUTION-',s(i+2)))
        xlabel('Thresholding Method')
        ylabel('R^2')
        %savefig(a,strcat("DEG_DIST_",s(i),'.fig'));
        %saveas(a,strcat("DEG_DIST_",s(i),'.jpg'),'jpeg');
        [~,~,stats]=anova1(squeeze([FitParameters_ms(1,i,:)  FitParameters_norm(1,i,:) FitParameters_nlink(1,i,:) FitParameters_shuffling(1,i,:)])',X);
        [c,~,h,~] = multcompare(stats,'Alpha',0.01);
        figure(h)
        title(strcat('FITTING NORMAL DEGREE DISTRIBUTION-',s(i+2)))
        %savefig(h,strcat("ANOVA_DEG_DIST_",s(i),'.fig'));
    
        %% media gaussiana di fitting
%           boxB=[FitParameters_ms(2,i,:) FitParameters_ms(4,i,:) FitParameters_ms(6,i,:) FitParameters_norm(2,i,:)  ...
%             FitParameters_norm(4,i,:) FitParameters_norm(6,i,:)];
        boxB=[squeeze(squeeze(FitParameters_ms(2,i,:))) squeeze(squeeze(FitParameters_nlink(2,i,:)))...
               squeeze(squeeze(FitParameters_norm(2,i,:))) squeeze(squeeze(FitParameters_shuffling(2,i,:)))];
        a=figure;
        b=boxplot(boxB,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
        hold on
        t=plot([0 1 2 3 4 5],ones(1,6).*60,'r--','LineWidth',2);
        title(strcat('MEAN OF NORMAL DEGREE DISTRIBUTION-',s(i+2)))
        xlabel('Thresholding Method')
        ylabel('MEAN')
        legend([t],{'Structural Target'})
        %savefig(a,strcat("MEAN_",s(i),'.fig'));
        %saveas(a,strcat("MEAN_",s(i),'.jpg'),'jpeg');
        [~,~,stats]=anova1(squeeze(boxB),X);
        [c,~,h,~] = multcompare(stats,'Alpha',0.01);
        figure(h)
        title(strcat('MEAN OF NORMAL DEGREE DISTRIBUTION-',s(i+2)))
        %savefig(h,strcat("ANOVA_MEAN_",s(i),'.fig'));
     end
end
  
    