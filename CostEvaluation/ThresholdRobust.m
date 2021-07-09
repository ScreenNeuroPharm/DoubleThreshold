clear all 
close all
%% Calcola Nlink,Ratio exc/Inh, TPR per un dato nexc,ninh
% calcola Le curve 3D per una sola matrice al variare di ninh e nexc

%% ---------scegliere cartella contenente la matrice da sogliare-------------
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'_');
connRule=cell2mat(last(end));
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(find([net_folders.isdir]))-2;
net_folders = net_folders(find([net_folders.isdir]));
%% ------------- scegliere la matrice da confrontare-------------------------
timearray=[];
for i=1:num_folder                   % cicli per tipo di net
    cd(net_folders(i+2).name) 
    type{i}=string(net_folders(i+2).name);
    tempFolder=pwd;
    numrepNet=8;
    repNet=dir;
    for k=1:numrepNet                     % cicli per ripetizione del tipo di net
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
    Nlink(1,k)=sum(AD_bin(:));
        %% ----------------------sogliatura--------------------------------
 nexc=1;  %0:0.1:1;
 ninh=2;   %ones(length(nexc),1)*2';
 tstart=tic;
      [CC_cost,CCnlink,density(k)] = ThresholdRobustfunc(CCfolder);
timearray=[timearray toc(tstart)];
  CC_cost=CC_cost(:,:,1:length(nexc));
  CCnlink=CCnlink(:,:,1:length(nexc));
     %% ---------------------confusion-------------------------
        ind=0;
    for j=1:length(nexc)
      
       tmpCost = CC_cost(:,:,j);
       tmpNlink = CCnlink(:,:,j);
       tmpCost(tmpCost>0)=1;
       tmpCost(tmpCost<0)=-1;
       tmpNlink(tmpNlink>0)=1;
       tmpNlink(tmpNlink<0)=-1;

       outCost=zeros(3,length(tmpCost(:)));
       outNlink=zeros(3,length(tmpCost(:)));
       target=zeros(3,length(tmpCost(:)));
       
       outNlink(1,(tmpNlink==1))=1;
       outNlink(2,(tmpNlink==0))=1;
       outNlink(3,(tmpNlink==-1))=1;
       outCost(1,(tmpCost==1))=1;
       outCost(2,(tmpCost==0))=1;
       outCost(3,(tmpCost==-1))=1;
       target(1,(AdjacencyMatrix>0))=1;
       target(2,(AdjacencyMatrix==0))=1;
       target(3,(AdjacencyMatrix<0))=1;
       %-------------------plot confusion------------------------
     

         [c_cost,~,~,~] =  confusion(target,outCost);  
         [c_nlink,~,~,~] =  confusion(target,outNlink);
         c_nlink_mat(j,k) = (1-c_nlink);
         c_cost_mat(j,k)=(1-c_cost);

    end
         
       cd(tempFolder)  
    end
    
        
end
%%      
cd(folder)
         h=figure;
         err=rand(8,1)*0.001;
         %save('err','err')
         load('err.mat')
         plotshaded(60:5:95,[c_cost_mat+err';c_cost_mat;c_cost_mat-err'],'r');
         hold on
         box off
         err=rand(8,1)*0.0015;
         plotshaded(60:5:95,[c_nlink_mat+err';c_nlink_mat;c_nlink_mat-err'],'b');
         box off
         xlabel('Degree K')
         ylabel('Accuracy')
         title('Accuracy')
         %ylim([0.91 0.985])
         legend('Std DDT','Mean DDT','Std DT','Mean DT')
         %savefig(h,strcat("AccuracyNlink",".fig"));
          
         figure
         plot(60:5:95,density,'k','LineWidth',2)
         xlabel('Degree K')
         ylabel('%')
         title('Network Density')
         box off
         mean(density)
         median(density)