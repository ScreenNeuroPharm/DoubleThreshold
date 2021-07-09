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
    numrepNet=3;
    repNet=dir;
    type{i}=string(net_folders(i+2).name);
    for k=1:numrepNet                     % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    temp_dir=dir;
    last=split(temp_dir(3).name,'_');
    date=cell2mat(last(1));
    cd('CrossCorrelation')
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
%         nexc=[ 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1...
%         0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1...
%         0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1];
%      ninh=[2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0...
%         2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.4 2.4 2.4 2.4 2.4 2.4 2.4 2.4 2.6 2.6 2.6 2.6 2.6 2.6 2.6 2.6...
%         2.8 2.8 2.8 2.8 2.8 2.8 2.8 2.8 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0];
    
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
        %number of link
        link_ms(i,k)=length(find(CC(:,:,1)>0));
        link_cost(i,k)=length(find(CC(:,:,2)>0));
        link_shuff(i,k)=length(find(CC(:,:,4)>0));
        link_nlink(i,k)=length(find(CC(:,:,3)>0));
        %ratio exc/inh
        link_ms_exc(i,k)=length(find(C(:,:,1)>0));
        link_ms_inh(i,k)=length(find(C(:,:,1)<0));
        link_cost_exc(i,k)=length(find(C(:,:,2)>0));
        link_cost_inh(i,k)=length(find(C(:,:,2)<0));
        link_nlink_exc(i,k)=length(find(C(:,:,3)>0));
        link_nlink_inh(i,k)=length(find(C(:,:,3)<0));
        link_shuff_exc(i,k)=length(find(C(:,:,4)>0));
        link_shuff_inh(i,k)=length(find(C(:,:,4)<0));
          
    end
    cd(folder)
end
%% --------------------------- boxplot --------------------------

s(1)="nexc=1_ninh=1";
s(2)="nexc=1_ninh=1";
s(3)="nexc=1_ninh=1";
s(4)="nexc=1_ninh=1";
trueRatio=[90 89 88]
upper = trueRatio+2;
lower = trueRatio-2;
%%
for i=1:3
    
%% --------------- Number of link-----------------
        a=figure
       X = categorical({'HD','DDT','DT','SH'});
        X = reordercats(X,{'HD','DDT','DT','SH'});
        Yn = [link_ms(i,:)' link_nlink(i,:)' link_cost(i,:)'  link_shuff(i,:)'];
        b=boxplot(Yn,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)         
        xlabel('Threshold Method')
        ylabel('Number of Links')
        title(strcat("Number of links ",type{i}));
        hold on 
        hold off
        box off
        ylim([700 4000])
        savefig(a,strcat("Nlink_",type{i},".fig"));
        saveas(a,strcat("Nlink_",type{i},'.jpg'),'jpeg');
%        [~,~,stats]=anova1(Y,X);
%        [c,~,h,~] = multcompare(stats,'Alpha',0.01);
%        figure(h)
%        title(strcat('Number of Links',s(i)))
%        savefig(h,strcat("ANOVA_Nlink_",s(i),".fig"));

%% --------------- Ratio exc/inh-------------------
     ratio_ms=(link_ms_exc./(link_ms_exc+link_ms_inh));
     ratio_cost=(link_cost_exc./(link_cost_exc+link_cost_inh));
     ratio_nlink=(link_nlink_exc./(link_nlink_exc+link_nlink_inh));
     ratio_shuff=(link_shuff_exc./(link_shuff_exc+link_shuff_inh));
     Yr=([ratio_ms(i,:)' ratio_cost(i,:)'...
         ratio_nlink(i,:)' ratio_shuff(i,:)'].*100);                        % 43--> nexc=1 ninh=2
        X = categorical({'HD','DDT','DT','SH'});
        X = reordercats(X,{'HD','DDT','DT','SH'});
        a=figure  
        b=boxplot(Yr,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2);
        xlabel('Threshold Method')
        ylabel('%')
        title(strcat("Ratio exc/inh ",type{i}));
        hold on 
        t=plot([0 1 2 3 4 5 ],trueRatio(i).*ones(6),'r--','LineWidth',2)
        plot([0 1 2 3 4 5 ],upper(i).*ones(6),'r--','LineWidth',1)
        plot([0 1 2 3 4 5 ],lower(i).*ones(6),'r--','LineWidth',1)
        legend([t],{'Structural Target'})
        box off
        ylim([60 97])
        savefig(a,strcat("Ratio_",type{i},".fig"));
        saveas(a,strcat("Ratio_",type{i},'.jpg'),'jpeg');
       [~,~,stats]=anova1(Yr,X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.05);
       figure(h)
       title(strcat('Ratio exc/inh',s(i)))
       savefig(h,strcat("ANOVA_Ratio_",s(i),".fig"));
end

   