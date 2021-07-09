
clr
check = 0;

[start_folder]= selectfolder('Select the PeakDetectionMAT_files folder');
if strcmp(num2str(start_folder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
elseif strfind(start_folder,'Split')
    check = 1;
end
 

% ------ PARAM ------
    nspikes = 3;
    ISImax = 100;
    mbr_thresh = 1;
    IBIwin = 10;
    IBIbin = 1;
    fs=1000;
    NumNeur=500;
% ------------------
peak_folder=start_folder;
cd(peak_folder)
[exp_num] = BurstDetection (peak_folder, nspikes, ISImax, mbr_thresh, fs, NumNeur, IBIwin, IBIbin);


