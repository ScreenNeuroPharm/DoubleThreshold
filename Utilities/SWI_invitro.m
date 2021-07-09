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
    type{i}=string(net_folders(i+2).name);
    tempFolder=pwd;
    numrepNet=3;
    repNet=dir;
    for k=1:numrepNet                     % cicli per ripetizione del tipo di net
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
        tmpMS = CC(:,:,1);
        tmpCost = CC(:,:,2);
        tmpNlink =  CC(:,:,3);
        tmpShuffling =  CC(:,:,4);
        
         n = size(tmpMS,1);  % number of nodes
         m = sum(sum(tmpMS)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWms(k,i),~,~] = small_world_ness2(tmpMS,Lrand,CrandWS,1);
         n = size(tmpCost,1);  % number of nodes
         m = sum(sum(tmpCost)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWcost(k,i),~,~] = small_world_ness2(tmpCost,Lrand,CrandWS,1);
          n = size(tmpNlink,1);  % number of nodes
         m = sum(sum(tmpNlink)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWnlink(k,i),~,~] = small_world_ness2(tmpNlink,Lrand,CrandWS,1);
         n = size(tmpShuffling,1);  % number of nodes
         tmpShuffling(isnan(tmpShuffling))=0;
         m = length(find(tmpShuffling==1)); %number of edges directed network
         [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
         [SWShuffle(k,i),Pl,CCsh] = small_world_ness2(tmpShuffling,Lrand,CrandWS,1);
         

    end
    cd(folder)
end
%%
for i=1:3
        a=figure
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        Y = [SWms(:,i)  SWnlink(:,i) SWcost(:,i)  SWShuffle(:,i)];
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2);         
        xlabel('Threshold Method')
        ylabel('SWI')
        title(strcat("SWI ",type{i}));
        ylim([1.5 4.5]);
        box off
        savefig(a,strcat("SWI_",type{i},".fig"));
        saveas(a,strcat("SWI_",type{i},'.jpg'),'jpeg');
       [~,~,stats]=anova1(Y,X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.05);
       figure(h)
       title('SWI')
       savefig(h,"ANOVA_SWI.fig");
end
% %% plot hardhreshold
%        a=figure
%        X = categorical({'Cx','He','Hp'});
%         X = reordercats(X,{'Cx','He','Hp'});
%         Y = [SWms];
%         b=boxplot(Y,X);
%         set(b,{'linew'},{2})
%         set(gca,'linew',2)         
%         xlabel('Networks')
%         ylabel('SWI')
%         title('SWI Hard Threshold');
%         savefig(a,strcat("SWI_HardTh",s(1),".fig"));
%         saveas(a,strcat("SWI_HardTh",s(1),'.jpg'),'jpeg');
%        [~,~,stats]=anova1([SWms],X);
%        [c,~,h,~] = multcompare(stats);
%        figure(h)
%        title('SWI')
%        savefig(h,"ANOVA_HardTh.fig");
%        %% plot nlink
%        a=figure
%         X = categorical({'Cx','He','Hp'});
%         X = reordercats(X,{'Cx','He','Hp'});
%         Y = [SWnlink];
%         b=boxplot(Y,X);
%         set(b,{'linew'},{2})
%         set(gca,'linew',2)         
%         xlabel('Networks')
%         ylabel('SWI')
%         title('SWI Density Threshold');
%         savefig(a,strcat("SWI_Density",s(1),".fig"));
%         saveas(a,strcat("SWI_Density",s(1),'.jpg'),'jpeg');
%        [~,~,stats]=anova1([SWms],X);
%        [c,~,h,~] = multcompare(stats);
%        figure(h)
%        title('SWI')
%        savefig(h,"ANOVA_Density.fig");
%         %% plot Double Threshold
%         a=figure
%         X = categorical({'Cx','He','Hp'});
%         X = reordercats(X,{'Cx','He','Hp'});
%         Y = [SWcost];
%         b=boxplot(Y,X);
%         set(b,{'linew'},{2})
%         set(gca,'linew',2)        
%         xlabel('Networks')
%         ylabel('SWI')
%         title('SWI Double Threshold');
%         savefig(a,strcat("SWI_DoubleTh",s(1),".fig"));
%         saveas(a,strcat("SWI_DoubleTh",s(1),'.jpg'),'jpeg');
%        [~,~,stats]=anova1([SWms],X);
%        [c,~,h,~] = multcompare(stats);
%        figure(h)
%        title('SWI')
%        savefig(h,"ANOVA_DoubleTh.fig");
%         %% plot Shuffling
%         a=figure
%         X = categorical({'Cx','He','Hp'});
%         X = reordercats(X,{'Cx','He','Hp'});
%         Y = [SWShuffle];
%         b=boxplot(Y,X);
%         set(b,{'linew'},{2})
%         set(gca,'linew',2)
%         xlabel('Networks')
%         ylabel('SWI')
%         title('SWI Shuffling');
%         savefig(a,strcat("SWI_Shuffling",s(1),".fig"));
%         saveas(a,strcat("SWI_Shuffling",s(1),'.jpg'),'jpeg');
%        [~,~,stats]=anova1([SWms],X);
%        [c,~,h,~] = multcompare(stats);
%        figure(h)
%        title('SWI')
%        savefig(h,"ANOVA_Shuffling.fig");