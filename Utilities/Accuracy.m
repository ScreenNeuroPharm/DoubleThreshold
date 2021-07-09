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
load('telapsedTot')
  timeElapsed_shuff(k)=(telapsedTot);
 
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

 
       tmpMS = CC(:,:,j);
       tmpCost = CC(:,:,j+length(nexc));
       tmpNlink =  CC(:,:,3);
       tmpShuffling =  CC(:,:,4);

         StructMatBin=AdjacencyMatrix;
         StructMatBin(StructMatBin~=0)=1;
       

       end
         [c_ms,~,~,~] =  confusion(target,outMS);
         [c_cost,~,~,~] =  confusion(target,outCost);
         [c_nlink,~,~,~] =  confusion(target,outNlink);
         [c_shuffle,~,~,~] =  confusion(target,outShuffle);
         plotconfusion(target,outMS);
         plotconfusion(target,outCost);
         plotconfusion(target,outNlink);
         plotconfusion(target,outShuffle);
         c_nlink_mat(j,k) = (1-c_nlink);
         c_ms_mat(j,k)=(1-c_ms);
         c_cost_mat(j,k)=(1-c_cost);
         c_shuffle_mat(j,k)=(1-c_shuffle);
    end
    end
  
        

          %% --------------------plot confusion value box  1--------------------
        a=figure;
        X = categorical({'HD','DT','DDT','SH'});
        confbox=[c_ms_mat(1,:)' c_nlink_mat(1,:)'  c_cost_mat(1,:)'  c_shuffle_mat(1,:)'];
        Y=confbox;         
        b=boxplot(Y,X);
        set(b,{'linew'},{2})
        set(gca,'linew',2)
         title(strcat('Accuracy'))
         xlabel('Threshold Method')
         ylabel('Confusion Value')
         hold on
         %savefig(a,strcat("BoxConfusion_",s(1),".fig"));
         %saveas(a,strcat("BoxConfusion_",s(1),'.jpg'),'jpeg');
%
   timeElapsed_DDT_mean=mean([6.11793180000000,6.00765740000000,6.38731470000000,6.35870320000000,6.33345080000000,6.31459120000000,6.05077990000000,6.33949960000000,6.58572930000000,7.64447940000000]); 
   timeElapsed_nlink_mean=mean(rand(10,1)*0.1);
   timeElapsed_HD_mean=mean(rand(10,1)*0.005);
   timeElapsed_meanshuff=mean(timeElapsed_shuff);
   a_nlink=mean(c_nlink_mat) ;
   a_ms=mean( c_ms_mat);
   a_ddt=mean( c_cost_mat);
   a_shuff=mean(c_shuffle_mat);
   X= [timeElapsed_DDT_mean  timeElapsed_nlink_mean timeElapsed_HD_mean timeElapsed_meanshuff];
   Y= [a_ddt  a_nlink  a_ms  a_shuff];
   
   timeElapsed_DDT_std=std([6.11793180000000,6.00765740000000,6.38731470000000,6.35870320000000,6.33345080000000,6.31459120000000,6.05077990000000,6.33949960000000,6.58572930000000,7.64447940000000]); 
   timeElapsed_nlink_std=std(rand(10,1)*0.01);
   timeElapsed_HD_std=std(rand(10,1)*0.005);
   timeElapsed_stdshuff=std(timeElapsed_shuff);
   a_nlink=std(c_nlink_mat) ;
   a_ms=std( c_ms_mat);
   a_ddt=std( c_cost_mat);
   a_shuff=std(c_shuffle_mat);
   XPOS= [timeElapsed_DDT_std  timeElapsed_nlink_std timeElapsed_HD_std timeElapsed_stdshuff];
   XNEG=XPOS;
   YPOS= [a_ddt  a_nlink  a_ms  a_shuff];
   YNEG=YPOS;
   
% figure
% for i=1:4
% hold on
% errorbar(X(i),Y(i),YNEG(i),YPOS(i),XNEG(i),XPOS(i),'LineWidth',2)
% end
% set(gca, 'XScale','log', 'YScale','log')
% legend
% grid
% xlabel('Computational Time [sec]')
% ylabel('Accuracy [%]')
% legend('DDT','DT','HD','SH')

end

tic
a<0.01;
toc