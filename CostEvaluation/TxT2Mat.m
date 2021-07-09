% This script converts the peak train stored in ascii format (.txt) in
% Matlab sparse format (.mat). This is the correct file format to run the
% analysis using the developed scripts and Matlab functions.
% The same directories tree are mantained. Time stamps and peak 
% amplitudes are stored.
% 
%                 Paolo Massobrio - last update 7th May 2020
% 

clear all
start_folder = uigetdir(pwd, 'Select the MAIN Peak Detection TXT folder');
out_folder = start_folder(1:end-4);
mkdir(out_folder);
cd(start_folder);
d = dir; % main directory del peak train
for j = 3:length(d)
    subfold_name = d(j).name;
    cd(subfold_name);
    subfold_path = pwd;
    dd = dir;
    for k = 3:length(dd)
        filename = dd(k).name;
        pt = load(filename);
        dur_sample = pt(1,1);
        peak_train = zeros(dur_sample,1);
        peak_train(pt(:,1))=pt(:,2);
        peak_train = sparse(peak_train);
        artifact = [];
        cd(out_folder);
        if ~exist(subfold_name)
            mkdir(subfold_name);
        end
        cd(subfold_name);
        filename_out = [filename(1:end-3),'mat'];
        save(filename_out,'peak_train','artifact','-mat');
        cd(subfold_path);
    end
    cd ..
end
cd ..\..
clear all
disp('End Of Processing!');