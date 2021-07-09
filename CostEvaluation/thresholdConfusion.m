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
num_folder=length(find([net_folders.isdir]))-2;
net_folders = net_folders(find([net_folders.isdir]));
%------------- scegliere la matrice da confrontare-------------------------
for i=1 %num_folder-1                     % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=6;                                                           %length(dir)-2
    repNet=dir;
    for k=1:numrepNet                    % cicli per ripetizione del tipo di net
    
    close all
    cd(repNet(k+2).name)
    temp_dir=dir;
    last=split(temp_dir(3).name,'_');
    date=cell2mat(last(1));
    cd(strcat(date,'_CrossCorrelation'))
    CCfolder=pwd;
    cd(start_folder)
    cd(net_folders(i+2).name)
    cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_900_sec.mat')
 
    AD_bin=AdjacencyMatrix;
    AD_bin(AD_bin>0)=1;
    AD_bin(AD_bin<0)=-1;
    Nlink(1,k)=length(find(AdjacencyMatrix<0))+length(find(AdjacencyMatrix>3));
    n=size(AD_bin,1);
%         % ----------------------sogliatura--------------------------------
    nexc=[1];
    ninh=[2];
cd(CCfolder)
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
  

    %% ---------------------confusion-------------------------
        ind=0;
    for j=1:length(nexc)
       
       tmpMS = C(:,:,j);
       tmpCost = C(:,:,j+length(nexc));
       tmpNlink = C(:,:,3);
       tmpShuffle = C(:,:,4);
       tmpMS(tmpMS>0)=1;
       tmpMS(tmpMS<0)=-1;
       tmpCost(tmpCost>0)=1;
       tmpCost(tmpCost<0)=-1;
       tmpNlink(tmpNlink>0)=1;
       tmpNlink(tmpNlink<0)=-1;
       tmpShuffle(tmpShuffle>0)=1;
       tmpShuffle(tmpShuffle<0)=-1;
       outMS=zeros(3,length(tmpMS(:)));
       outCost=zeros(3,length(tmpMS(:)));
       outNlink=zeros(3,length(tmpMS(:)));
       outShuffle=zeros(3,length(tmpMS(:)));
       target=zeros(3,length(tmpMS(:)));
       
       outMS(1,(tmpMS==1))=1;
       outMS(2,(tmpMS==0))=1;
       outMS(3,(tmpMS==-1))=1;
       outNlink(1,(tmpNlink==1))=1;
       outNlink(2,(tmpNlink==0))=1;
       outNlink(3,(tmpNlink==-1))=1;
       outCost(1,(tmpCost==1))=1;
       outCost(2,(tmpCost==0))=1;
       outCost(3,(tmpCost==-1))=1;
       outShuffle(1,(tmpShuffle==1))=1;
       outShuffle(2,(tmpShuffle==0))=1;
       outShuffle(3,(tmpShuffle==-1))=1;
       target(1,(AD_bin==1))=1;
       target(2,(AD_bin==0))=1;
       target(3,(AD_bin==-1))=1;
       %-------------------plot confusion------------------------
       if  j == 1    %( j == 21   || j == 61)3 
       ind=ind+1;
       f=figure;
       a=plotconfusion(target,outMS,'Hard Threshold',...
            target,outCost,'Double-Threshold',...
            target,outNlink,'Density Threshold',...
            target,outShuffle,'Shuffling');
figure
 a=plotconfusion (target,outCost,'Double-Threshold')
       xticklabels({'Exc','no-conn','Inh'})
       yticklabels({'Exc','no-conn','Inh'})
       figure
 b=plotconfusion( target,outNlink,'Density Threshold')
       xticklabels({'Exc','no-conn','Inh'})
       yticklabels({'Exc','no-conn','Inh'})
       %savefig(f,strcat("Confusion_",string(nexc(j)),'_',string(ninh(j)),'_net_',string(k),'.fig'));
       %saveas(f,strcat("Confusion_",string(nexc(j)),'_',string(ninh(j)),'_net_',string(k),'.jpg'),'jpeg');
       tmpMS = CC(:,:,j);
       tmpCost = CC(:,:,j+length(nexc));
       tmpNlink =  CC(:,:,3);
       tmpShuffling =  CC(:,:,4);

%          StructMatBin=AdjacencyMatrix;
%          StructMatBin(StructMatBin~=0)=1;
%          [Lrand,CrandWS] = NullModel_L_C(size(StructMatBin,1),sum(sum(StructMatBin)),100,1);
%          [SW(k,ind),~,~] = small_world_ness2(StructMatBin,Lrand,CrandWS,1);
%          n = size(tmpMS,1);  % number of nodes
%          m = sum(sum(tmpMS)); %number of edges directed network
%          [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
%          [SWms(k,ind),~,~] = small_world_ness2(tmpMS,Lrand,CrandWS,1);
%          n = size(tmpCost,1);  % number of nodes
%          m = sum(sum(tmpCost)); %number of edges directed network
%          [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
%          [SWcost(k,ind),~,~] = small_world_ness2(tmpCost,Lrand,CrandWS,1);
%           n = size(tmpNlink,1);  % number of nodes
%          m = sum(sum(tmpNlink)); %number of edges directed network
%          [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
%          [SWnlink(k,ind),~,~] = small_world_ness2(tmpNlink,Lrand,CrandWS,1);
%          n = size(tmpShuffling,1);  % number of nodes
%          m = sum(sum(tmpShuffling)); %number of edges directed network
%          [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
%          [SWShuffle(k,ind),~,~] = small_world_ness2(tmpShuffling,Lrand,CrandWS,1);

       end
         [c_ms,~,~,~] =  confusion(target,outMS);
         [c_cost,~,~,~] =  confusion(target,outCost);
         [c_nlink,~,~,~] =  confusion(target,outNlink);
         [c_shuffle,~,~,~] =  confusion(target,outShuffle);
         c_nlink_mat(j,k) = (1-c_nlink);
         c_ms_mat(j,k)=(1-c_ms);
         c_cost_mat(j,k)=(1-c_cost);
         c_shuffle_mat(j,k)=(1-c_shuffle);
    end
    end
  
        
% %% ---------------------plot SWI ------------------------------
%     ind=0;
%     for n=[1]
%         ind=ind+1;
%         a=figure; 
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
%         Y=([ SWms(:,ind) SWnlink(:,ind) SWcost(:,ind) SWShuffle(:,ind)]);         
%         b=boxplot(Y,X);
%         set(b,{'linew'},{2})
%         set(gca,'linew',2)
%         xlabel('Threshold Method')
%         ylabel('Small World Index')
%         title('Small World Index');
%         hold on
%         t=plot([0 1 2 3 4 5],ones(1,6).*mean(SW),'r--','LineWidth',2);
%         legend([t],{'Structural'})
%         savefig(a,strcat("SWI_",s(ind),".fig"));
%         saveas(a,strcat("SWI_",s(ind),'.jpg'),'jpeg');
%        [~,~,stats]=anova1([SWms(:,ind) SWnlink(:,ind) SWcost(:,ind) SWShuffle(:,ind)],X);
%        [c,~,h,~] = multcompare(stats);
%        figure(h)
%        title(strcat('Small World Index',s(ind+2)))
%        savefig(h,strcat("ANOVA_SWI_",s(ind),".fig"));
% 
%     end
          %% --------------------plot confusion value box  1--------------------
        a=figure;
        confbox=[c_ms_mat(1,:)' c_nlink_mat(1,:)'  c_cost_mat(1,:)'  c_shuffle_mat(1,:)'];
        Y=confbox;         
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
         title(strcat('Confusion Value'))
         xlabel('Threshold Method')
         ylabel('Confusion Value')
         hold on
%          savefig(a,strcat("BoxConfusion_",s(1),".fig"));
% %          saveas(a,strcat("BoxConfusion_",s(1),'.jpg'),'jpeg');
%          [~,~,stats]=anova1(confbox,X);
%          [c,~,h,~] = multcompare(stats);
%          figure(h)
%          title(strcat('Confusion Value -',s(3)))
%          savefig(h,strcat("ANOVA_BoxConfusion_",s(1),'.fig'));
%             
%      %% ------------------------- plot ------------------------------------------
%  exc=[1];
%  inh=[2];
%  for ii=1:numrepNet
%    C=zeros(8,8,3);
%    C(:,:,1)=1;
%    a=figure;
%    surf(exc,inh,reshape(c_ms_mat(:,ii),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('fraction of samples classified')
%    hold on
%    
%    C=zeros(8,8,3);
%    C(:,:,2)=1;
%    surf(exc,inh,reshape(c_cost_mat(:,ii),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('fraction of samples classified')
%     xlabel('nexc')
%     ylabel('ninh')
%      
%     title('Confusion Value')
%     legend('mean-std','NEW')
%      savefig(a,strcat("ConfusionValue3D_",string(ii),".fig"));
%      saveas(a,strcat("ConfusionValue3D_",string(ii),'.jpg'),'jpeg');
%  end  
end
