close all
clear all

folder = uigetdir(pwd,'Select the folder that contains the simulation files:');
cd(folder)
RuleFolder=dir;
for k = [3,4,5]
cd(folder)
cd(RuleFolder(k).name)
connRule=RuleFolder(k).name;
start_folder=pwd;
net_folders=dir;
num_folder=length(dir)-2;
%% ------------- scegliere la matrice da confrontare-------------------------
% for i=1:num_folder                     % cicli per tipo di net
%     cd(string(i)) 
%     tempFolder=pwd;
%     cd('Electrophysiological_Analysis')
%     cd('01_PeakDetectionMAT_files_500neurons')
%     peak_folder=pwd;
%     % -------------------------- MFR ------------------------------
%       mfr_thresh = 0.001;
%     KernelWidth = [20 900]; % (ms) No more than 2!!!!
%     if length(KernelWidth) > 2
%         KernelWidth = KernelWidth(1:2);
%     end
%     undersamplingFactor = 1;
%     MFR(peak_folder, 500, 1000, mfr_thresh);
%     cd(start_folder)
% end
%%
for i=1:num_folder
    cd(string(i)) 
    cd('Electrophysiological_Analysis')
    tempFolder=pwd;
    cd('01_SpikeAnalysis')
    cd('01_MeanFiringRate - thresh_0.001')
    load('MFR_All1_1');
    mfr_exc(i,k-2)=mean(mfr_table(1:400,2));
    mfr_inh(i,k-2)=mean(mfr_table(401:end,2));
    mfr_tot(i,k-2)=mean(mfr_table(:,2));
    cd(start_folder)
end
end
%% boxplot MFR
MFR_exc = mean(mfr_exc);
MFR_exc_std = std(mfr_exc);
MFR_inh = mean(mfr_inh);
MFR_inh_std = std(mfr_inh);
MFR_tot = mean(mfr_tot);
MFR_tot_std = std(mfr_tot);
%%
columnHeaders = {'Total', 'Excitatory', 'Inhibitory'};
rowHeaders = {'RND','SF','SW'};
 
   tableData{1,1} = strcat(num2str(MFR_tot(1)),char(177),num2str(MFR_tot_std(1)),' sp/s');
  tableData{2,1} = strcat(num2str(MFR_tot(2)),char(177),num2str(MFR_tot_std(2)),' sp/s');
  tableData{3,1} = strcat(num2str(MFR_tot(3)),char(177),num2str(MFR_tot_std(3)),' sp/s');
    tableData{1,2} = strcat(num2str(MFR_exc(1)),char(177),num2str(MFR_exc_std(1)),' sp/s');
  tableData{2,2} = strcat(num2str(MFR_exc(2)),char(177),num2str(MFR_exc_std(2)),' sp/s');
  tableData{3,2} = strcat(num2str(MFR_exc(3)),char(177),num2str(MFR_exc_std(3)),' sp/s');
    tableData{1,3} = strcat(num2str(MFR_inh(1)),char(177),num2str(MFR_inh_std(1)),' sp/s');
  tableData{2,3} = strcat(num2str(MFR_inh(2)),char(177),num2str(MFR_inh_std(2)),' sp/s');
  tableData{3,3} = strcat(num2str(MFR_inh(3)),char(177),num2str(MFR_inh_std(3)),' sp/s');

% Create the table and display it.
hTable = uitable();
% Apply the row and column headers.
set(hTable, 'RowName', rowHeaders);
set(hTable, 'ColumnName', columnHeaders);
% Display the table of values.
set(hTable, 'data', tableData);
% Size the table.
set(hTable, 'units', 'normalized');
set(hTable, 'Position', [0.1 .1 .8 .8]);
set(hTable, 'ColumnWidth', {120, 120, 120});
set(gcf,'name','Image Analysis Demo','numbertitle','off')