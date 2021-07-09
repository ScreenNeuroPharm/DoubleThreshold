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
num_folder=length(dir)-2;
%% ------------- scegliere la matrice da confrontare-------------------------
for i=num_folder                   % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=6;
    repNet=dir;
    for k=1:numrepNet                     % cicli per ripetizione del tipo di net
   cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_1_sec.mat')
    load('ConnectivityMatrix_900_sec.mat')
    cd(start_folder)
    cd(net_folders(i+2).name)
    cd(repNet(k+2).name)
    cd('Electrophysiological_CrossCorrelation');
    CCfolder=pwd;
    AD_bin=AdjacencyMatrix;
    AD_bin(AD_bin>0)=1;
    AD_bin(AD_bin<0)=-1;
    Nlink(1,k)=length(find(AdjacencyMatrix<0))+length(find(AdjacencyMatrix>3));
    n=size(AD_bin,1);
%         % ----------------------sogliatura--------------------------------
    nexc=[0.5];
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
  
        s(1)="nexc=0.5_ninh=2";
        s(2)="nexc=0.5_ninh=2";
        s(3)="nexc=0.5 ninh=2";
        s(4)="nexc=0.5 ninh=2";
    %% ----------------------compute number of links-------------------------
    for ii=1:length(nexc)
        %number of link
        link_ms(ii,k)=length(find(CC(:,:,ii)>0));
        link_cost(ii,k)=length(find(CC(:,:,ii+length(nexc))>0));
        link_shuff(ii,k)=length(find(CC(:,:,4)>0));
        link_nlink(ii,k)=length(find(CC(:,:,3)>0));
        %ratio exc/inh
        link_ms_exc(ii,k)=length(find(C(:,:,ii)>0));
        link_ms_inh(ii,k)=length(find(C(:,:,ii)<0));
        link_cost_exc(ii,k)=length(find(C(:,:,ii+length(nexc))>0));
        link_cost_inh(ii,k)=length(find(C(:,:,ii+length(nexc))<0));
        link_nlink_exc(ii,k)=length(find(C(:,:,3)>0));
        link_nlink_inh(ii,k)=length(find(C(:,:,3)<0));
        link_shuff_exc(ii,k)=length(find(C(:,:,4)>0));
        link_shuff_inh(ii,k)=length(find(C(:,:,4)<0));
  %% total TPR
%             tempTP_ms=CC(:,:,ii)+AD_bin;
%             tempFN_ms=CC(:,:,ii)-AD_bin;
%             tempTP_cost=CC(:,:,ii+length(nexc))+AD_bin;
%             tempFN_cost=CC(:,:,ii+length(nexc))-AD_bin;
%             TPR_ms(ii,k)=length(find(tempTP_ms==2))./(length(find(tempFN_ms==-1))+length(find(tempTP_ms==2)));
%             TPR_cost(ii,k)=length(find(tempTP_cost==2))./(length(find(tempFN_cost==-1))+length(find(tempTP_cost==2)));

     end 
   
    end
%% --------------------------- boxplot --------------------------
ind=0;
s(1)="nexc=1_ninh=2";
s(2)="nexc=1_ninh=2";
s(3)="nexc=1_ninh=2";
s(4)="nexc=1_ninh=2";
for n=[1]
    ind=ind+1;
%% --------------- Number of link-----------------
        a=figure
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        Yn = single([link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)']);
        b=boxplot(Yn,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)         
        xlabel('Threshold Method')
        ylabel('Number of Links')
        title('Number of Links');
        %ylim([16500 22000]);
        box off
        hold on 
        t=plot([0 1 2 3 4 5 ],ones(6,1)*mean(Nlink),'r--','LineWidth',2)
        legend([t],{'Structural'})
        hold off
        %savefig(a,strcat("Nlink.fig"));
        %saveas(a,strcat("Nlink.png"),'png');
       [~,~,stats]=anova1([link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)' ],X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.01);
       figure(h)
       title(strcat('Number of Links',s(ind+2)))
       %savefig(h,strcat("ANOVA_Nlink_",s(ind),".fig"));

%% --------------- Ratio exc/inh-------------------
     ratio_ms=(link_ms_exc./(link_ms_exc+link_ms_inh))';
     ratio_cost=(link_cost_exc./(link_cost_exc+link_cost_inh))';
     ratio_nlink=(link_nlink_exc./(link_nlink_exc+link_nlink_inh))';
     ratio_shuff=(link_shuff_exc./(link_shuff_exc+link_shuff_inh))';
     Yr=single([ratio_ms(:,n) ratio_cost(:,n)...
         ratio_nlink(:,n) ratio_shuff(:,n)].*100);                        % 43--> nexc=1 ninh=2
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        a=figure  
        b=boxplot(Yr,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2);
        xlabel('Threshold Method')
        ylabel('%')
        title('Ratio exc/inh');
        ylim([74 86])
        box off
        hold on 
        t=plot([0 1 2 3 4 5 ],ones(6,1)*80,'r--','LineWidth',2)
        legend([t],{'Structural'})
        %savefig(a,strcat("Ratio.fig"));
        %saveas(a,strcat("Ratio.png"),'png');
       [~,~,stats]=anova1([link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)' ],X);
       [c,~,h,~] = multcompare(stats,'Alpha',0.01);
       figure(h)
       title(strcat('Ratio exc/inh',s(ind+2)))
       %savefig(h,strcat("ANOVA_Ratio_",s(ind),".fig"));
end
end