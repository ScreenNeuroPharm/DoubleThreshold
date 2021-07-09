%% main shuffling 
clear all 
close all
% number of nets
main_folder = uigetdir(pwd,'Select the folder in which create the simulation files:');
cd(main_folder)
deg=60:5:100;
numExp=length(deg);
dirExp=dir;
for k = 9:numExp
    mkdir(string(k))
    cd(string(k))
    MainNetDelaySTDPFunction('MOD',deg(k))
    cd(main_folder)
end