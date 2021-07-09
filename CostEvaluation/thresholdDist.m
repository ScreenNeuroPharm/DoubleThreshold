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
    AD_bin(AD_bin~=0)=1;
    Nlink(1,k)=sum(AD_bin(:));
        %% ----------------------sogliatura--------------------------------
    nexc=[1];
    ninh=[2];
%         nexc=[ 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1...
%         0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1...
%         0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1];
%      ninh=[2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0...
%         2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.2 2.4 2.4 2.4 2.4 2.4 2.4 2.4 2.4 2.6 2.6 2.6 2.6 2.6 2.6 2.6 2.6...
%         2.8 2.8 2.8 2.8 2.8 2.8 2.8 2.8 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0];
    n_inh=[6.5 4.2 4.7 5.7 5 5];
    [CC_meanstd,CC_cost,CC_bin_meanstd,CC_bin_cost,CCnlink,CCshuff] = ThresholdMatrixEvaluation(CCfolder,nexc,ninh,n_inh(k));
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
        Y = [link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)'];
        b=boxplot(Y,X);
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
%        [~,~,stats]=anova1([link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)' ],X);
%        [c,~,h,~] = multcompare(stats,'Alpha',0.01);
%        figure(h)
%        title(strcat('Number of Links',s(ind+2)))
%        savefig(h,strcat("ANOVA_Nlink_",s(ind),".fig"));

%% --------------- Ratio exc/inh-------------------
     ratio_ms=(link_ms_exc./(link_ms_exc+link_ms_inh))';
     ratio_cost=(link_cost_exc./(link_cost_exc+link_cost_inh))';
     ratio_nlink=(link_nlink_exc./(link_nlink_exc+link_nlink_inh))';
     ratio_shuff=(link_shuff_exc./(link_shuff_exc+link_shuff_inh))';
     Y=([ratio_ms(:,n) ratio_cost(:,n)...
         ratio_nlink(:,n) ratio_shuff(:,n)].*100);                        % 43--> nexc=1 ninh=2
        X = categorical({'HD','DT','DDT','SH'});
        X = reordercats(X,{'HD','DT','DDT','SH'});
        a=figure  
        b=boxplot(Y,X);
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
        savefig(a,strcat("Ratio.fig"));
        saveas(a,strcat("Ratio.png"),'png');
%        [~,~,stats]=anova1([link_ms(n,:)' link_nlink(n,:)' link_cost(n,:)'  link_shuff(n,:)' ],X);
%        [c,~,h,~] = multcompare(stats,'Alpha',0.01);
%        figure(h)
%        title(strcat('Ratio exc/inh',s(ind+2)))
%        savefig(h,strcat("ANOVA_Ratio_",s(ind),".fig"));
end
end
%%
% for i=1:numrepNet
%  %% ------------------------- plot ------------------------------------------
%  exc=[1];
%  inh=[2];
%  %% -----------------------------NINK-----------------------------------
%    C=zeros(8,8,3);
%    C(:,:,1)=1;
%    f=figure;
%    surf(exc,inh,reshape((link_ms(:,i)),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('N links')
%    hold on
%    C=zeros(8,8,3);
%    C(:,:,2)=1;
%    
%    surf(exc,inh,reshape((link_cost(:,i)),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('N links')
%    hold on
%    C=zeros(8,8,3);
%    C(:,:,3)=1;
%    
%    surf(exc,inh,ones(8).*mean(Nlink),C,'FaceAlpha',0.5)
%     xlabel('nexc')
%     ylabel('ninh')
%     zlabel('N links')
%     
%     title('Number Of Link')
%     legend('mean-std','NEW','Real Number Connection')
%     savefig(f,strcat("Nlink_3D_",string(i),".fig"));
%      
%% ----------------------------- RATIO exc/inh -----------------------------
% ratio_ms=((link_ms_exc./(link_ms_exc+link_ms_inh))');
% ratio_cost=((link_cost_exc./(link_cost_exc+link_cost_inh))');
% 
% 
%    C=zeros(8,8,3);
%    C(:,:,1)=1;
%    f=figure
%    surf(exc,inh,reshape(ratio_ms(i,:),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('EXC/INH')
%    hold on
%    C=zeros(8,8,3);
%    C(:,:,2)=1;
%    
%    surf(exc,inh,reshape(ratio_cost(i,:),[8 8])',C,'FaceAlpha',0.5)
%    zlabel('EXC/INH')
%    hold on
%    C=zeros(8,8,3);
%    C(:,:,3)=1;
%    
%    surf(exc,inh,ones(8).*0.8,C,'FaceAlpha',0.5)
%     xlabel('nexc')
%     ylabel('ninh')
%     zlabel('EXC/INH')
%     
%     title('Ratio EXC/INH')
%     legend('mean-std','NEW','Structural 80/20')
%     savefig(f,strcat("RATIO_3D_",string(i),".fig"));
%     
%     %% -----------------------------TPR -----------------------------
% 
%    C=zeros(8,8,3);
%    C(:,:,1)=1;
%    f=figure
%    surf(exc,inh,reshape(TPR_ms(:,i),[8 8])',C,'FaceAlpha',0.5)
%    xlabel('nexc')
%    ylabel('ninh')
%    zlabel('TPR')
%    hold on
%    C=zeros(8,8,3);
%    C(:,:,2)=1;
%    
%    surf(exc,inh,reshape(TPR_cost(:,i),[8 8])',C,'FaceAlpha',0.5)
%    xlabel('nexc')
%    ylabel('ninh')
%    zlabel('TPR')
% %    hold on 
% %    C=zeros(8,8,3);
% %    C(:,:,3)=1;
% %    surf(exc,inh,ones(8).*0.9,C,'FaceAlpha',0.5)
%    title('TPR')
%    legend('mean-std','NEW')
%    savefig(f,strcat("TPR_3D_",string(i),".fig"));
% %    %% TPR exc
% %     C=zeros(8,8,3);
% %    C(:,:,1)=1;
% %    figure
% %    surf(exc,inh,reshape(mean(TPR_ms_exc'),[8 8])',C,'FaceAlpha',0.5)
% %    xlabel('nexc')
% %    ylabel('ninh')
% %    zlabel('TPR exc')
% %    hold on
% %    C=zeros(8,8,3);
% %    C(:,:,2)=1;
% %    
% %    surf(exc,inh,reshape(mean(TPR_cost_exc'),[8 8])',C,'FaceAlpha',0.5)
% %    xlabel('nexc')
% %    ylabel('ninh')
% %    zlabel('TPR exc')
% %    hold on 
% %    C=zeros(8,8,3);
% %    C(:,:,3)=1;
% %    surf(exc,inh,ones(8).*0.9,C,'FaceAlpha',0.5)
% %    title('TPR exc')
% %    legend('mean-std','cost','tpr=0.9')
% %    %% TPR INH
% %     C=zeros(8,8,3);
% %    C(:,:,1)=1;
% %    figure
% %    surf(exc,inh,reshape(mean(TPR_ms_inh'),[8 8])',C,'FaceAlpha',0.5)
% %    xlabel('nexc')
% %    ylabel('ninh')
% %    zlabel('TPR inh')
% %    hold on
% %    C=zeros(8,8,3);
% %    C(:,:,2)=1;
% %    
% %    surf(exc,inh,reshape(mean(TPR_cost_inh'),[8 8])',C,'FaceAlpha',0.5)
% %    xlabel('nexc')
% %    ylabel('ninh')
% %    zlabel('TPR inh')
% %    hold on 
% %    C=zeros(8,8,3);
% %    C(:,:,3)=1;
% %    surf(exc,inh,ones(8).*0.9,C,'FaceAlpha',0.5)
% %    title('TPR Inh')
% %    legend('mean-std','cost','tpr=0.9')
% close all    
% end   