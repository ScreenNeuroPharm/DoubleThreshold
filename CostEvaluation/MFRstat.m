close all
clear all

%%
folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
last=split(folder,'\');
cd(folder)
start_folder=pwd;
net_folders=dir;
num_folder=length(dir)-2;
for i =  1
    cd(net_folders(i+2).name);
    connRule= net_folders(i+2).name;
    type_folders = dir;
    num_type_folder=length(dir)-2;
    topology_folder=pwd;
    for j = 1:6
        cd(string(j)) 
        tempFolder=pwd;
        cd('MFR_Analisys')
        load('mfr')
        mean_mfr(j,i)=mean(mfr);

       

        cd(topology_folder)
        close all
    end

   cd(folder)
end
