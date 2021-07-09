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
for i=1 %num_folder-1                     % cicli per tipo di net
    cd(net_folders(i+2).name) 
    tempFolder=pwd;
    numrepNet=6;
    repNet=dir;
    for k=1:numrepNet                       % cicli per ripetizione del tipo di net
    close all
    cd(repNet(k+2).name)
    cd('Topological_Analysis')
    load('ConnectivityMatrix_900_sec.mat')
    cd(start_folder)
    cd(net_folders(i+2).name)
    cd(repNet(k+2).name)
    cd('Electrophysiological_CrossCorrelation');
    CCfolder=pwd;
    AD_bin=AdjacencyMatrix;
    AD_bin(AD_bin~=0)=1;
    Nlinkexc(1,k)=length(find(AdjacencyMatrix>0));
    Nlinkinh(1,k)=length(find(AdjacencyMatrix<0));
    
        %% ----------------------sogliatura--------------------------------

    nexc=repmat(0:0.1:1.5,[1 16]);
    ninh=repelem(1:0.1:2.5,16);

    [CC_meanstd,CC_bin_meanstd] = ThresholdMatrix1(CCfolder,nexc,ninh,syn,1);
    n=length(CC_meanstd);
    CC=zeros(n,n,length(nexc));
    CC(:,:,1:length(nexc))=CC_bin_meanstd;


    C=zeros(n,n,length(nexc));
    C(:,:,1:length(nexc))=CC_meanstd;
    clear CC_bin_meanstd  CC_meanstd
    cd(tempFolder)
    %% ---------------------confusion-------------------------
    ind=0;
    AD_bin=AdjacencyMatrix;
    AD_bin(AD_bin>0)=1;
    AD_bin(AD_bin<0)=-1;
    
    for j=1:length(nexc)
       
       tmpMS = C(:,:,j);
       tmpMS(tmpMS>0)=1;
       %tmpMS(tmpMS<0)=0;
       outMS=zeros(2,length(tmpMS(:)));
       target=zeros(2,length(tmpMS(:)));
       outMS(1,(tmpMS==1))=1;
       outMS(2,(tmpMS==0))=1;
       target(1,(AD_bin==1))=1;
       target(2,(AD_bin==0))=1;
       [Cexctmp,~,~,~] = confusion(target,outMS);
       Cexc(j,k)= 1-Cexctmp;
       
       tmpMS = C(:,:,j);
       tmpMS(tmpMS<0)=-1;
       %tmpMS(tmpMS>0)=0;
       outMS=zeros(2,length(tmpMS(:)));
       target=zeros(2,length(tmpMS(:)));
       outMS(1,(tmpMS==-1))=1;
       outMS(2,(tmpMS==0))=1;
       target(1,(AD_bin==-1))=1;
       target(2,(AD_bin==0))=1;
       [Cinhtmp,~,~,~] = confusion(target,outMS);
       Cinh(j,k)=1-Cinhtmp;

    end
    
     for ii=1:length(nexc)
        %-------------------------number of link---------------------------
        link_ms(ii,k)=length(find(CC(:,:,ii)>0));
        %link_cost(ii,k)=length(find(CC(:,:,ii+length(nexc))>0));
        %ratio exc/inh
        link_ms_exc(ii,k)=length(find(C(:,:,ii)>0));
        link_ms_inh(ii,k)=length(find(C(:,:,ii)<0));
        %link_cost_exc(ii,k)=length(find(C(:,:,ii+length(nexc))>0));
        %link_cost_inh(ii,k)=length(find(C(:,:,ii+length(nexc))<0));
        ratio_ms(ii,k)=(link_ms_exc(ii,k)./(link_ms_exc(ii,k)+link_ms_inh(ii,k)))';
%         %-------------------------- positive TPR---------------------------
%             temp_AD_bin=AdjacencyMatrix;
%             temp_AD_bin(temp_AD_bin<0)=0;
%             temp_AD_bin(temp_AD_bin>0)=1;
%             tmp=C(:,:,ii);
%             tmp(tmp<0)=0;
%             tmp(tmp>0)=1;
%             tempTP_ms=tmp+temp_AD_bin;
%             tempFN_ms=tmp-temp_AD_bin;
% %             tmp=C(:,:,ii+length(nexc));
% %             tmp(tmp<0)=0;
% %             tmp(tmp>0)=1;
% %             tempTP_cost=tmp+temp_AD_bin;
% %             tempFN_cost=tmp-temp_AD_bin;
%             TPR_ms_exc(ii,k)=length(find(tempTP_ms==2))./(length(find(tempFN_ms==1))+length(find(tempTP_ms==2)));
% %            TPR_cost_exc(ii,k)=length(find(tempTP_cost==2))./(length(find(tempFN_cost==1))+length(find(tempTP_cost==2)));
%            %----------------------- Inh TPR -------------------------------
%             temp_AD_bin=AdjacencyMatrix;
%             temp_AD_bin(temp_AD_bin>0)=0;
%             temp_AD_bin(temp_AD_bin<0)=1;
%             
%             tmp=C(:,:,ii);
%             tmp(tmp>0)=0;
%             tmp(tmp<0)=1;
%            
%             tempTP_ms=tmp+temp_AD_bin;
%             tempFN_ms=tmp-temp_AD_bin;
% %             tmp=C(:,:,ii+length(nexc));
% %             tmp(tmp>0)=0;
% %             tmp(tmp<0)=1;
% %            
% %             tempTP_cost=tmp+temp_AD_bin;
% %             tempFN_cost=tmp-temp_AD_bin;
%             TPR_ms_inh(ii,k)=length(find(tempTP_ms==2))./(length(find(tempFN_ms==1))+length(find(tempTP_ms==2)));
% %            TPR_cost_inh(ii,k)=length(find(tempTP_cost==2))./(length(find(tempFN_cost==-1))+length(find(tempTP_cost==2)));
     end 
    end
end


    
%% ------------------------ plot Nlink -------------------------------
% -------------------------- exc Nlink--------------------------------
figure

bar(nexc(1:16),mean(link_ms_exc(1:16,:),2));
pos_err = std(link_ms_exc(1:16,:),0,2);
neg_err = -std(link_ms_exc(1:16,:),0,2);
hold on 
er = errorbar(nexc(1:16),mean(link_ms_exc(1:16,:),2),pos_err,neg_err); 
title('Number of excitatory links');
xlabel('n exc')
ylabel('Num of link')
er.Color = [1 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 2;
plot(linspace(0,1.6,17),ones(1,17).*Nlinkexc(1),'--g','LineWidth',2)
legend('Mean','Std','Structural Target')
hold off
% -------------------------- inh Nlink--------------------------------
figure
bar(ninh(1:16:end),mean(link_ms_inh(1:16:end,:),2));
pos_err = std(link_ms_inh(1:16:end,:),0,2);
neg_err = -std(link_ms_inh(1:16:end,:),0,2);
hold on 
er = errorbar(ninh(1:16:end),mean(link_ms_inh(1:16:end,:),2),pos_err,neg_err); 
title('Number of inhibitory links');
xlabel('n inh')
ylabel('Num of link')
er.Color = [1 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 2;
plot(linspace(1,2.5,17),ones(1,17).*Nlinkinh(1),'--g','LineWidth',2)
legend('Mean','Std','Structural Target')
hold off
%% ------------------------ plot TPR -------------------------------

figure
bar(nexc(1:16),mean(Cexc(1:16,:),2));
pos_err = std(Cexc(1:16,:),0,2);
neg_err = -std(Cexc(1:16,:),0,2);
hold on 
er = errorbar(nexc(1:16),mean(Cexc(1:16,:),2),pos_err,neg_err); 
title('Fraction of classified excitatory links');
xlabel('n exc')
ylabel('Fraction of links')
er.Color = [1 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 2;
legend('Mean','Std')
hold off
% -------------------------- inh Nlink--------------------------------
figure
bar(ninh(1:16:end),mean(Cinh(1:16:end,:),2));
pos_err = std(Cinh(1:16:end,:),0,2);
neg_err = -std(Cinh(1:16:end,:),0,2);
hold on 
er = errorbar(ninh(1:16:end),mean(Cinh(1:16:end,:),2),pos_err,neg_err); 
title('Fraction of classified inhibitory links');
xlabel('n inh')
ylabel('Fraction of links')
er.Color = [1 0 0];                            
er.LineStyle = 'none';  
er.LineWidth = 2;
legend('Mean','Std')
hold off
%% --------------------------- Ratio exc/inh ------------------------

   C=zeros(16,16,3);
   C(:,:,3)=1;
   f=figure
   surf(nexc(1:16),ninh(1:16:end),reshape(ratio_ms(:,1),[16 16])',C,'FaceAlpha',0.8)
   zlabel('EXC/INH')
   hold on
   
   C=zeros(16,16,3);
   C(:,:,1)=1;
   surf(nexc(1:16),ninh(1:16:end),ones(16).*0.90,C,'FaceAlpha',0.3)
    xlabel('nexc')
    ylabel('ninh')
    zlabel('EXC/INH')
    
   C=zeros(16,16,3);
   C(:,:,2)=1;
   surf(nexc(1:16),ninh(1:16:end),ones(16).*0.70,C,'FaceAlpha',0.3)
    xlabel('nexc')
    ylabel('ninh')
    zlabel('EXC/INH')
    
    title('Ratio EXC/INH')
    legend('thresholded','Structural 90','Structural 70')
    savefig(f,strcat("RATIO_3D_",string(i),".fig"));