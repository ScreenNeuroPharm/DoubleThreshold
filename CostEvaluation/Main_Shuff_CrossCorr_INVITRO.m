% Main_Shuff_CrossCorr_INVITRO
%this script evaluate cross-correlogram, connectivity matrix and a shuffled
%dataset for in vitro mea recording from 60 up to 256 el. 

close all
clear all
clc

%% ---------scegliere cartella in cui sono contenuti gli esperimenti-------------
%check if the folder contains folders in which exist PeakDetectionMAT
SaRa=10000;
MainFolder = uigetdir(pwd,'Select the folder that contains the simulation files:');   %Folder that contains all the Data
last=split(MainFolder,'\');
MainFolder_name=cell2mat(last(end));                                      
cd(MainFolder)
MainFolderDirectory=dir;
Number_of_NetType=length(dir)-2;

for i = 1:Number_of_NetType                                                %cycle over NetType
    cd(MainFolderDirectory(i+2).name)
    NameofTypeFolder=MainFolderDirectory(i+2).name;                        %Name of the i-th type folder
    TypeFolder=pwd;                                                        %Adress of i-th type folder
    Number_of_exp_perNetType=length(dir)-2;
    TypeFolderDirectory=dir;
    for j=1:2%Number_of_exp_perNetType                                       %cycle over TypeExperiment
         cd(TypeFolderDirectory(j+2).name)             
         SingleExpFolder=pwd;
         SingleExpFiles=dir;
         cd(SingleExpFiles(3).name)
         peak_folder=pwd;
         start=tic;
         fprintf("Cross-Correlation is going... \n");
         STPE_shuff_INVITRO(SaRa,peak_folder,SingleExpFolder,0)            %launch correlation with and with out shuffling
         toc(start)
         start=tic;
         fprintf("Shuffling is going... \n");
         STPE_shuff_INVITRO(SaRa,peak_folder,SingleExpFolder,1)
         toc(start)
         cd(TypeFolder)

    end
             
 cd(MainFolder)
end


