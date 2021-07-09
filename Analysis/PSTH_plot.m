function [] = PSTH_plot(psthfiles_folder, psthresults_folder, NumNeur)
% PLOT_MULTIPLE_PSTH.m
% Multiple plot for PSTH files
% Script by Michela Chiappalone Nov 18, 2003
% Revised and adapted for long term tetanic experiments (Paolo Massobrio, 18th March 2009)
% Revised and adapted for simulations
% 
%                    Paolo Massobrio last update 10th October 2016
% 

warning off;
num_stimel = {1};                           % to set!!!!

cd (psthfiles_folder)
name_dir = dir;
name_dir_cell = struct2cell(name_dir);
name_dir_cell = name_dir_cell(1,3)';        % Only names of the directories - cell array

% ********************************************************************
% --------------- USER information
PSTHtime = {'400'};   % 400 ms time course of the PSTH

cd (psthresults_folder);
[exp_num] = find_expnum(psthfiles_folder, '_');
storage_dir = strcat(exp_num,'_PSTHplot_stimPhases_',(num2str(num_stimel{1})),'_win',(PSTHtime{1}),'_bin',psthfiles_folder(end-8),'ms');
mkdir (storage_dir);
cd (storage_dir);
output_dir = pwd;
cd(psthfiles_folder);

% --------------- PSTH parameters
xlim  =  str2double(PSTHtime{1,1}); % X-axis limit for the plot
binindex1 = strfind(psthfiles_folder, 'bin');
binindex2 = strfind(psthfiles_folder, '-');
binsize = str2num(psthfiles_folder(binindex1+3:binindex2(end)-1));
timeframeindex = strfind(psthfiles_folder, 'msec');
timeframe = str2num(psthfiles_folder(binindex2(end)+1:timeframeindex-1));
x = binsize*[1:timeframe/binsize];
%***********************************************************************

coll = ['k','r','b','g','y']; % color table

NumNeurArray = [1:NumNeur]';

for i=1:fix(length(name_dir_cell)/num_stimel{1,1})
    sep = max(cell2mat(strfind(name_dir_cell,'_')));
    stimoli(i)=str2double(name_dir_cell{i}(sep+1:end));
end

for k=1:length(stimoli)
    stimel = stimoli(k); % name of the stimulating electrodes - double
    [index]=findfolderStim(name_dir_cell, stimel);
    psthPeak = [];
    for j=1:length(index)
        folder_path= strcat (psthfiles_folder, '\', name_dir_cell{index(j)});
        cd(folder_path);
        d = dir;
        for ii = 3:length(d)
            psthPeak = [];
            filename = d(ii).name;
            load(filename);
            Neu= NumNeurArray(ii-2); % name of the considered electrode - double
            psthcnt = psthcnt/binsize*1000;
            psthPeak = [psthPeak,max(psthcnt)];
            y = plot(x, psthcnt, 'col', coll(j), 'LineWidth', 2);
            hold on
            if max(psthPeak) == 0
                y_lim = 1;
                flag = 0;
            else
                y_lim = ceil(max(psthPeak));
                flag = 1;
            end
            axis ([1 str2double(PSTHtime{1}) 0 y_lim]);
            titolo = strcat('PSTH stim', num2str(stimel), ' neuron ', num2str(Neu));
            title(titolo,'FontSize',14,'FontName','arial');
            xlabel('Time relative to stimulus (ms)','FontSize',14,'FontName','arial');
            ylabel('Spike Frequency (sp/s)','FontSize',14,'FontName','arial');
            set(gca, 'FontSize',14, 'FontName','arial');
            %     legend ('Test Stim 1', 'Test Stim 2', 'After 2 h', 'After 24 h', 'After 48 h','FontSize',14,'FontName','arial');
            nome= strcat('cumPSTH_stim', num2str(stimel), '_', num2str(Neu));
            clear psthPeak
            cd (output_dir)
            if flag == 1      % saving only PSTH with area different from 0
                saveas(y,nome,'jpg');
                saveas(y,nome,'fig');
            end
            cd (psthfiles_folder)
            close all;
            cd(folder_path);
        end
    end
end
cd(psthresults_folder);
cd ..
