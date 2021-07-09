function [psthfiles_folder, psthresults_folder, exp_num] = ManagePSTHfiles(peak_folder, binsize, psthend)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


    [exp_num] = find_expnum(peak_folder, '_PeakDetectionMAT');

    cd(peak_folder);
    cd ..
    end_folder = pwd;
    psthfoldername1 = strcat ('PSTHfiles_bin', num2str(binsize),'-', num2str(psthend),'msec');   % Save the PSTH files here
    psthfoldername2 = strcat ('PSTHresults_bin', num2str(binsize),'-', num2str(psthend),'msec'); % Save additional PSTH features (latency, etc.) here

    [psthfiles_folder] = createresultfolder(end_folder, exp_num, psthfoldername1);
    [psthresults_folder] = createresultfolder(end_folder, exp_num, psthfoldername2);
    clear psthfoldername1 psthfoldername2

    cd (peak_folder)
